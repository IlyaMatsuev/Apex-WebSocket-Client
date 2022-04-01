public class WSListenEventHandler extends WSEventHandler {
    @TestVisible
    private static EventPublisher eventPublisher = new EventPublisher();

    public WSListenEventHandler(List<SObject> events) {
        super(events);
    }

    public override WSAsyncJob createJob(SObject event) {
        WSListenEvent__e listenEvent = (WSListenEvent__e) event;
        return new ListenJob(
            listenEvent.ClientId__c,
            (List<WSHandlerWrapper>) JSON.deserialize(listenEvent.Handlers__c, List<WSHandlerWrapper>.class)
        );
    }

    private class ListenJob extends WSAsyncJob {
        private final String clientId;
        private final List<WSHandlerWrapper> handlers;

        private Long calloutTime = 0;

        public ListenJob(String clientId, List<WSHandlerWrapper> handlers) {
            this.clientId = clientId;
            this.handlers = handlers;
        }

        public override void execute() {
            DateTime calloutStart = DateTime.now();
            WSResponsePayload response = WSDispatcherService.listen(clientId);
            calloutTime += DateTime.now().getTime() - calloutStart.getTime();

            if (!response.success) {
                // TODO: Should I publish error events?
                throw new WSConnection.ConnectionException('Failed to listen: ' + response.firstMessage);
            }

            if (response.event != WSResponsePayload.ResponseEvent.Timeout) {
                List<WSUpdateEvent__e> updates = new List<WSUpdateEvent__e>();
                for (WSHandlerWrapper handler : handlers) {
                    if (handler.ofType(response.event.name())) {
                        updates.add(createUpdateEvent(response, handler));
                    }
                }
                eventPublisher.publish(updates);
            }

            if (response.event != WSResponsePayload.ResponseEvent.Close) {
                again();
            }
        }

        private WSUpdateEvent__e createUpdateEvent(WSResponsePayload response, WSHandlerWrapper handler) {
            return new WSUpdateEvent__e(
                ClientId__c = response.clientId,
                Messages__c = JSON.serialize(response.messages),
                Type__c = handler.updateType.name(),
                HandlerClassName__c = handler.className,
                Arguments__c = JSON.serialize(handler.args)
            );
        }

        private void again() {
            if (isUnderCalloutCountLimit() && isUnderCalloutTimeLimit() && isUnderCpuTimeLimit()) {
                execute();
            } else {
                WSDispatcherService.listenAsync(clientId, handlers);
            }
        }

        private Boolean isUnderCalloutCountLimit() {
            return Limits.getCallouts() < Limits.getLimitCallouts();
        }

        private Boolean isUnderCalloutTimeLimit() {
            return calloutTime + WSDispatcherSettings.getTimeout() <= WSDispatcherSettings.HTTP_MAX_TIMEOUT;
        }

        private Boolean isUnderCpuTimeLimit() {
            return Limits.getCpuTime() + WSDispatcherSettings.CPU_TIME_SCOPE < Limits.getLimitCpuTime();
        }
    }

    // TODO: Do I really need it?
    // Needed for testing purpose
    @TestVisible
    private virtual class EventPublisher {
        public virtual void publish(List<SObject> events) {
            EventBus.publish(events);
        }
    }
}
