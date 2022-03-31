public abstract class WSEventHandler {
    protected final List<SObject> events;

    public WSEventHandler(List<SObject> events) {
        this.events = events;
    }

    // TODO: Double check the logic to prevent recursive running
    public virtual void handle() {
        List<SObject> anotherChunk = new List<SObject>();
        for (Integer i = 0; i < events.size(); i++) {
            if (i < Limits.getLimitQueueableJobs()) {
                WSAsyncJob.run(createJob(events.get(i)));
            } else {
                anotherChunk.add(events.get(i));
            }
        }
        EventBus.publish(anotherChunk);
    }

    public abstract WSAsyncJob createJob(SObject event);
}
