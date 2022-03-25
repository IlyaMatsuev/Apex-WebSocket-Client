public class WSDispatcherService {
    @TestVisible
    private static EventPublisher eventPublisher = new EventPublisher();

    public WSResponsePayload connect(String endpoint, String protocol) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Connect, endpoint, protocol));
    }

    public void listen(String clientId, List<WSHandlerWrapper> handlers) {
        WSAsyncJob.run(new ListenJob(clientId, handlers));
    }

    public WSResponsePayload message(String clientId, String message) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Message, clientId, message));
    }

    public WSResponsePayload close(String clientId) {
        return call(new WSRequestPayload(WSRequestPayload.RequestCommand.Close, clientId));
    }

    private static WSResponsePayload call(WSRequestPayload payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WSDispatcherSettings.getEndpoint());
        request.setTimeout(WSDispatcherSettings.getTimeout());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload.toJson());
        return WSResponsePayload.fromJson(new Http().send(request).getBody());
    }

    private class ListenJob extends WSAsyncJob {
        private final String clientId;
        private final List<WSHandlerWrapper> handlers;

        public ListenJob(String clientId, List<WSHandlerWrapper> handlers) {
            this.clientId = clientId;
            this.handlers = handlers;
        }

        public override void execute() {
            WSResponsePayload response = call(new WSRequestPayload(WSRequestPayload.RequestCommand.Listen, clientId));
            if (!response.success) {
                // TODO: Should I publish error events?
                throw new WSConnection.ConnectionException('Failed to listen: ' + response.firstMessage);
            }

            if (response.event != WSResponsePayload.ResponseEvent.Timeout) {
                List<WSUpdate__e> updates = new List<WSUpdate__e>();
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

        private WSUpdate__e createUpdateEvent(WSResponsePayload response, WSHandlerWrapper handler) {
            return new WSUpdate__e(
                ClientId__c = response.clientId,
                Messages__c = JSON.serialize(response.messages),
                Type__c = handler.updateType.name(),
                HandlerClassName__c = handler.className,
                Arguments__c = JSON.serialize(handler.args)
            );
        }

        private void again() {
            if (
                Limits.getCallouts() >= Limits.getLimitCallouts() ||
                Limits.getCpuTime() + WSDispatcherSettings.CPU_TIME_SCOPE >= Limits.getLimitCpuTime()
            ) {
                WSAsyncJob.run(this);
            } else {
                execute();
            }
        }
    }

    // Needed for testing purpose
    @TestVisible
    private virtual class EventPublisher {
        public virtual void publish(List<SObject> events) {
            EventBus.publish(events);
        }
    }
}
