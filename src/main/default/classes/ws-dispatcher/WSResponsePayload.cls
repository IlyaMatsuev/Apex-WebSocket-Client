public class WSResponsePayload {
    public final String clientId;
    public final ResponseEvent event;
    public final List<String> messages;

    public WSResponsePayload(ResponseEvent event, String message) {
        this.event = event;
        this.messages = new List<String>{ message };
    }

    public Boolean isSuccess() {
        return event != ResponseEvent.Error;
    }

    public String getFirstMessage() {
        return messages.isEmpty() ? null : messages.get(0);
    }

    public static WSResponsePayload fromJson(String response) {
        return (WSResponsePayload) JSON.deserialize(response, WSResponsePayload.class);
    }

    public enum ResponseEvent {
        Connect,
        Timeout,
        Message,
        Error,
        Close
    }
}
