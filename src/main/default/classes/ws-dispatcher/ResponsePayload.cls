public class ResponsePayload {
    public final String clientId;
    public final ResponseEvent event;
    public final List<String> messages;

    public ResponsePayload(ResponseEvent event, String message) {
        this.event = event;
        this.messages = new List<String> { message };
    }

    public Boolean isSuccess() {
        return event == ResponseEvent.Error;
    }

    public static ResponsePayload fromJson(String response) {
        return (ResponsePayload) JSON.deserialize(response, ResponsePayload.class);
    }

    public enum ResponseEvent {
        Connect,
        Timeout,
        Message,
        Error,
        Close
    }
}
