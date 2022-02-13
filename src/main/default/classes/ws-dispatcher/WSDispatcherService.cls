public class WSDispatcherService {
    private static WSDispatcherSetting__c dispatcherSetting {
        get {
            if (dispatcherSetting == null) {
                dispatcherSetting = WSDispatcherSetting__c.getOrgDefaults();
            }
            return dispatcherSetting;
        }
        set;
    }

    public static ResponsePayload connect(String endpoint, String protocol) {
        return call(new RequestPayload(RequestPayload.RequestCommand.Connect, endpoint, protocol));
    }

    public static void listen(String clientId, List<NotificationHandler> handlers) {
        AsyncContainer.run(new ListenDelegate(clientId));
    }

    public static void message(String clientId, String message, List<NotificationHandler> handlers) {
        AsyncContainer.run(new MessageDelegate(clientId, message));
    }

    public static ResponsePayload close(String clientId) {
        return call(new RequestPayload(RequestPayload.RequestCommand.Close, clientId));
    }

    private static void await(
        AsyncContainer.IDelegate delegate,
        RequestPayload payload,
        List<NotificationHandler> handlers
    ) {
        ResponsePayload response = call(payload);
        switch on response.event {
            when Message, Error, Close {
                List<WSUpdate__e> updates = new List<WSUpdate__e>();
                for (NotificationHandler handler : handlers) {
                    if (handler.ofType(response.event.name())) {
                        updates.add(handler.toEvent());
                    }
                }
                Eventbus.publish(updates);
            }
            when Timeout {
                AsyncContainer.run(delegate);
            }
        }
    }

    private static ResponsePayload call(RequestPayload payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(dispatcherSetting.Endpoint__c);
        request.setTimeout(dispatcherSetting.Timeout__c.intValue());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload.toJson());
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 500) {
            return new ResponsePayload(ResponsePayload.ResponseEvent.Error, response.getBody());
        }
        return ResponsePayload.fromJson(response.getBody());
    }

    private class ListenDelegate implements AsyncContainer.IDelegate {
        private final String clientId;
        private final List<NotificationHandler> handlers;

        public ListenDelegate(String clientId, List<NotificationHandler> handlers) {
            this.clientId = clientId;
            this.handlers = handlers;
        }

        public void run() {
            await(this, new RequestPayload(RequestPayload.RequestCommand.Listen, clientId), handlers);
        }
    }

    private class MessageDelegate implements AsyncContainer.IDelegate {
        private final String clientId;
        private final String message;
        private final List<NotificationHandler> handlers;

        public MessageDelegate(String clientId, String message, List<NotificationHandler> handlers) {
            this.clientId = clientId;
            this.message = message;
            this.handlers = handlers;
        }

        public void run() {
            await(this, new RequestPayload(RequestPayload.RequestCommand.Message, clientId, message), handlers);
        }
    }
}
