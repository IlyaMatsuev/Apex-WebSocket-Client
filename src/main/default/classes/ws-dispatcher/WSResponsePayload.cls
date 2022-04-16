public class WSResponsePayload {
    public final String clientId;
    public final ResponseEvent event;
    public final List<String> messages;

    public String firstMessage {
        get {
            return messages?.isEmpty() == false ? messages.get(0) : null;
        }
    }

    public Boolean success {
        get {
            return event != ResponseEvent.Error;
        }
    }

    private WSResponsePayload(ResponseEvent event, String clientId, String message) {
        this.event = event;
        this.clientId = clientId;
        this.messages = new List<String>{ message };
    }

    public static WSResponsePayload fromJson(String response) {
        return (WSResponsePayload) JSON.deserialize(response, WSResponsePayload.class);
    }

    public static WSResponsePayload getTimeoutResponse(String clientId) {
        return new WSResponsePayload(ResponseEvent.Timeout, clientId, 'Timeout. Reconnect again');
    }

    public enum ResponseEvent {
        Connect,
        Timeout,
        Message,
        Error,
        Close
    }
}
