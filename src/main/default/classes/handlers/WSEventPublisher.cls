// Need this publisher due to some issues regarding testing async-event-async functionality
public virtual class WSEventPublisher {
    public virtual void publish(List<SObject> events) {
        EventBus.publish(events);
    }
}
