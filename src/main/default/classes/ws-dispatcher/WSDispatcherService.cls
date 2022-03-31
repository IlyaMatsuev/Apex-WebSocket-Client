public class WSDispatcherService {
    public static WSResponsePayload connect(String endpoint, String protocol) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Connect, endpoint, protocol));
    }

    public static WSResponsePayload listen(String clientId) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Listen, clientId));
    }

    public static void listenAsync(String clientId, List<WSHandlerWrapper> handlers) {
        publishListenEvent(clientId, handlers);
    }

    public static WSResponsePayload message(String clientId, String message) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Message, clientId, message));
    }

    public static WSResponsePayload close(String clientId) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Close, clientId));
    }

    private static WSResponsePayload call(WSRequestPayload payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WSDispatcherSettings.getEndpoint());
        request.setTimeout(WSDispatcherSettings.getTimeout());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload.toJson());
        return WSResponsePayload.fromJson(new Http().send(request).getBody());
    }

    private static void publishListenEvent(String clientId, List<WSHandlerWrapper> handlers) {
        EventBus.publish(new WSListenEvent__e(ClientId__c = clientId, Handlers__c = JSON.serialize(handlers)));
    }
}
