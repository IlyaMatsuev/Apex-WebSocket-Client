public class RequestPayload {
    public final RequestCommand command;
    public final String clientId;
    public final String message;
    public final String endpoint;
    public final String protocol;

    public RequestPayload(RequestCommand command, String clientIdOrEndpoint) {
        this(command, clientIdOrEndpoint, null);
    }

    public RequestPayload(
        RequestCommand command,
        String clientIdOrEndpoint,
        String messageOrProtocol
    ) {
        this.command = command;
        if (command == RequestCommand.Connect) {
            this.endpoint = clientIdOrEndpoint;
            this.protocol = messageOrProtocol;
        } else {
            this.clientId = clientIdOrEndpoint;
            this.message = messageOrProtocol;
        }
    }

    public String toJson() {
        return JSON.serialize(this, true);
    }

    public enum RequestCommand {
        Connect,
        Listen,
        Message,
        Close
    }
}
