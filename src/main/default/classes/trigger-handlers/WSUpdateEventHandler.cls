public class WSUpdateEventHandler extends WSAsyncJob {
    private final List<WSUpdate__e> events;

    public WSUpdateEventHandler(List<WSUpdate__e> events) {
        this.events = events;
    }

    public void handle() {
        WSAsyncJob.run(this);
    }

    public override void execute() {
        for (WSUpdate__e event : events) {
            WSConnection connection = createConnection(event);
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(event.Arguments__c);
            WSMessageHandler handler = (WSMessageHandler) Type.forName(event.HandlerClassName__c).newInstance();
            handler.handle(connection, args);
        }
    }

    private WSConnection createConnection(WSUpdate__e event) {
        return new WSConnection(
            event.ClientId__c,
            (List<String>) JSON.deserialize(event.Messages__c, List<String>.class)
        );
    }
}
