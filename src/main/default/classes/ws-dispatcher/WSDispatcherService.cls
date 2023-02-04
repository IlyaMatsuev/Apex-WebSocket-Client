public class WSDispatcherService {
    public static WSResponsePayload connect(String endpoint, String protocol) {
        return call(
            new WSRequestPayload(
                WSRequestPayload.RequestCommand.Connect,
                new Map<String, Object> { 'endpoint' => endpoint, 'protocol' => protocol }
            )
        );
    }

    public static WSResponsePayload listen(String clientId) {
        return call(
            new WSRequestPayload(
                WSRequestPayload.RequestCommand.Listen,
                new Map<String, Object> { 'clientId' => clientId, 'timeout' => WSDispatcherSettings.getTimeout() }
            )
        );
    }

    public static void listenAsync(String clientId, List<WSHandlerWrapper> handlers) {
        publishListenEvent(clientId, handlers);
    }

    public static WSResponsePayload message(String clientId, String message) {
        return call(
            new WSRequestPayload(
                WSRequestPayload.RequestCommand.Message,
                new Map<String, Object> { 'clientId' => clientId, 'message' => message }
            )
        );
    }

    public static WSResponsePayload close(String clientId) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Close, clientId));
    }

    private static WSResponsePayload call(WSRequestPayload payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WSDispatcherSettings.getEndpoint());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload.toJson());
        if (payload.command == WSRequestPayload.RequestCommand.Listen) {
            request.setTimeout(WSDispatcherSettings.getTimeout());
        }
        try {
            return WSResponsePayload.fromJson(new Http().send(request).getBody());
        } catch (Exception error) {
            if (error instanceof CalloutException && error.getMessage().containsIgnoreCase('Read timed out')) {
                return WSResponsePayload.getTimeoutResponse(payload.clientId);
            }
            throw error;
        }
    }

    private static void publishListenEvent(String clientId, List<WSHandlerWrapper> handlers) {
        EventBus.publish(new WSListenEvent__e(ClientId__c = clientId, Handlers__c = JSON.serialize(handlers)));
    }
}
