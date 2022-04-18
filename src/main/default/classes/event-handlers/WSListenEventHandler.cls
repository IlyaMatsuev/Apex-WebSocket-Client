public class WSListenEventHandler extends WSEventHandler {
    @TestVisible
    private static EventPublisher eventPublisher = new EventPublisher();

    public WSListenEventHandler(List<SObject> events) {
        super(events);
    }

    public override WSAsyncJob createJob(SObject event) {
        WSListenEvent__e listenEvent = (WSListenEvent__e) event;
        List<WSHandlerWrapper> handlers = new List<WSHandlerWrapper>();
        for (Object handler : (List<Object>) JSON.deserializeUntyped(listenEvent.Handlers__c)) {
            Map<String, Object> handlerFields = (Map<String, Object>) handler;
            handlers.add(
                new WSHandlerWrapper(
                    WSHandlerWrapper.EventType.valueOf((String) handlerFields.get('eventType')),
                    Type.forName((String) handlerFields.get('className')),
                    (Map<String, Object>) handlerFields.get('args')
                )
            );
        }
        return new ListenJob(listenEvent.ClientId__c, handlers);
    }

    private class ListenJob extends WSAsyncJob {
        private final String clientId;
        private final List<WSHandlerWrapper> handlers;

        private Long calloutTime = 0;

        public ListenJob(String clientId, List<WSHandlerWrapper> handlers) {
            this.clientId = clientId;
            this.handlers = handlers;
        }

        // TODO: If the ws server is down and we submit listen job with error handler, then it won't stop
        public override void execute() {
            DateTime calloutStart = DateTime.now();
            WSResponsePayload response = WSDispatcherService.listen(clientId);
            calloutTime += DateTime.now().getTime() - calloutStart.getTime();

            if (response.event != WSResponsePayload.ResponseEvent.Timeout) {
                List<WSUpdateEvent__e> updates = new List<WSUpdateEvent__e>();
                for (WSHandlerWrapper handler : handlers) {
                    if (handler.ofType(response.event.name())) {
                        updates.add(createUpdateEvent(response, handler));
                    }
                }
                if (!response.success && updates.isEmpty()) {
                    throw new WSConnection.ConnectionException('Failed to listen: ' + response.firstMessage);
                }
                eventPublisher.publish(updates);
            }

            if (response.success && response.event != WSResponsePayload.ResponseEvent.Close) {
                listenAgain();
            }
        }

        private WSUpdateEvent__e createUpdateEvent(WSResponsePayload response, WSHandlerWrapper handler) {
            return new WSUpdateEvent__e(
                ClientId__c = response.clientId,
                Messages__c = JSON.serialize(response.messages),
                HandlerClassName__c = handler.className,
                Arguments__c = JSON.serialize(handler.args)
            );
        }

        private void listenAgain() {
            // TODO: Probably should execute again only if we got Timeout response. Otherwise a lot of jobs are queued
            if (isUnderCalloutCountLimit() && isUnderCalloutTimeLimit()) {
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
    }

    @TestVisible
    private virtual class EventPublisher {
        public virtual void publish(List<SObject> events) {
            EventBus.publish(events);
        }
    }
}
