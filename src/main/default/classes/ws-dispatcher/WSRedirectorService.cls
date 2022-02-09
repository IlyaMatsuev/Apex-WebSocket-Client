public class WSRedirectorService {
    public static ResponsePayload connect(String endpoint, String protocol) {
        return call(
            new RequestPayload(RequestPayload.RequestCommand.Connect, endpoint, protocol)
        );
    }

    public static void listen(String clientId) {
        AsyncContainer.run(new ListenDelegate(clientId));
    }

    public static void message(String clientId, String message) {
        AsyncContainer.run(new MessageDelegate(clientId, message));
    }

    public static ResponsePayload close(String clientId) {
        return call(new RequestPayload(RequestPayload.RequestCommand.Close, clientId));
    }

    private static void await(AsyncContainer.IDelegate delegate, RequestPayload payload) {
        ResponsePayload response = call(payload);
        switch on response.event {
            when Message {
                // TODO: Fire events somehow somewhere?
            }
            when Error {
                // TODO: Fire events somehow somewhere?
            }
            when Close {
                // TODO: Fire events somehow somewhere?
            }
            when Timeout {
                AsyncContainer.run(delegate);
            }
        }
    }

    private static ResponsePayload call(RequestPayload payload) {
        HttpRequest request = new HttpRequest();
        // TODO: Take endpoint, additional headers and timeout from the custom setting or metadata
        request.setEndpoint('');
        request.setTimeout(40000);
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

        public ListenDelegate(String clientId) {
            this.clientId = clientId;
        }

        public void run() {
            await(
                this,
                new RequestPayload(RequestPayload.RequestCommand.Listen, clientId)
            );
        }
    }

    private class MessageDelegate implements AsyncContainer.IDelegate {
        private final String clientId;
        private final String message;

        public MessageDelegate(String clientId, String message) {
            this.clientId = clientId;
            this.message = message;
        }

        public void run() {
            await(
                this,
                new RequestPayload(RequestPayload.RequestCommand.Message, clientId, message)
            );
        }
    }
}
