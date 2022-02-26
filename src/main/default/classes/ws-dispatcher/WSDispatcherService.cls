public class WSDispatcherService {
    private static final Integer HTTP_MAX_TIMEOUT = 120000;
    private static final Integer CPU_TIME_SCOPE = 3000;

    private static WSDispatcherSetting__c dispatcherSetting = WSDispatcherSetting__c.getOrgDefaults();
    private static String endpoint {
        get {
            String settingValue = dispatcherSetting.Endpoint__c;
            if (String.isBlank(settingValue)) {
                throw new CalloutException('No endpoint has been provided in the WS Dispatcher Settings');
            }
            return settingValue;
        }
    }
    private static Integer timeout {
        get {
            Integer settingValue = dispatcherSetting.Timeout__c?.intValue();
            if (settingValue == null || settingValue > HTTP_MAX_TIMEOUT) {
                System.debug(
                    LoggingLevel.WARN,
                    'No timeout has been specified in the WS Dispatcher Settings. Consider using max timeout'
                );
                settingValue = HTTP_MAX_TIMEOUT;
            }
            return settingValue;
        }
    }

    public static WSResponsePayload connect(String endpoint, String protocol) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Connect, endpoint, protocol));
    }

    public static void listen(String clientId, List<WSHandlerWrapper> handlers) {
        WSAsyncJob.run(new ListenJob(clientId, handlers));
    }

    public static WSResponsePayload message(String clientId, String message) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Message, clientId, message));
    }

    public static WSResponsePayload close(String clientId) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Close, clientId));
    }

    private static WSResponsePayload call(WSRequestPayload payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setTimeout(timeout);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload.toJson());
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 500) {
            return new WSResponsePayload(WSResponsePayload.ResponseEvent.Error, response.getBody());
        }
        return WSResponsePayload.fromJson(response.getBody());
    }

    private class ListenJob extends WSAsyncJob {
        private final String clientId;
        private final List<WSHandlerWrapper> handlers;

        public ListenJob(String clientId, List<WSHandlerWrapper> handlers) {
            this.clientId = clientId;
            this.handlers = handlers;
        }

        public override void execute() {
            WSResponsePayload response = call(new WSRequestPayload(WSRequestPayload.RequestCommand.Listen, clientId));
            if (!response.isSuccess()) {
                throw new WSConnection.ConnectionException('Failed to listen: ' + response.getFirstMessage());
            }

            if (response.event != WSResponsePayload.ResponseEvent.Timeout) {
                List<WSUpdate__e> updates = new List<WSUpdate__e>();
                for (WSHandlerWrapper handler : handlers) {
                    if (handler.ofType(response.event.name())) {
                        updates.add(createUpdateEvent(response, handler));
                    }
                }
                Eventbus.publish(updates);
            }

            if (response.event == WSResponsePayload.ResponseEvent.Close) {
                return;
            }

            again();
        }

        private WSUpdate__e createUpdateEvent(WSResponsePayload response, WSHandlerWrapper handler) {
            return new WSUpdate__e(
                ClientId__c = response.clientId,
                Messages__c = JSON.serialize(response.messages),
                Type__c = handler.updateType.name(),
                HandlerClassName__c = handler.className,
                Arguments__c = JSON.serialize(handler.args)
            );
        }

        private void again() {
            if (
                Limits.getCallouts() >= Limits.getLimitCallouts() ||
                Limits.getCpuTime() + CPU_TIME_SCOPE >= Limits.getLimitCpuTime()
            ) {
                WSAsyncJob.run(this);
            } else {
                execute();
            }
        }
    }
}
