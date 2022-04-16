public class WSRequestPayload {
    public final RequestCommand command;
    private final Map<String, Object> fields;

    public String clientId {
        get {
            return (String) fields.get('clientId');
        }
    }

    public WSRequestPayload(RequestCommand command, String clientId) {
        this(command, new Map<String, Object>{ 'clientId' => clientId });
    }

    public WSRequestPayload(RequestCommand command, Map<String, Object> fields) {
        this.fields = fields == null ? new Map<String, Object>() : fields;
        this.command = command;
    }

    public String toJson() {
        fields.put('command', command.name());
        return JSON.serialize(fields, true);
    }

    public enum RequestCommand {
        Connect,
        Listen,
        Message,
        Close
    }
}
