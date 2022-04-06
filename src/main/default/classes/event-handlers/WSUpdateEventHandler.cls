public class WSUpdateEventHandler extends WSEventHandler {
    public WSUpdateEventHandler(List<SObject> events) {
        super(events);
    }

    public override WSAsyncJob createJob(SObject event) {
        return new ExecuteUpdateHandlerJob((WSUpdateEvent__e) event);
    }

    private class ExecuteUpdateHandlerJob extends WSAsyncJob {
        private final WSUpdateEvent__e event;

        public ExecuteUpdateHandlerJob(WSUpdateEvent__e event) {
            this.event = event;
        }

        public override void execute() {
            WSConnection connection = new WSConnection(
                event.ClientId__c,
                (List<String>) JSON.deserialize(event.Messages__c, List<String>.class)
            );
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(event.Arguments__c);
            IWSMessageHandler handler = (IWSMessageHandler) Type.forName(event.HandlerClassName__c).newInstance();
            handler.handle(connection, args);
        }
    }
}
