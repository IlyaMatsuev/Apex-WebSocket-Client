public abstract class WSEventHandler {
    protected final List<SObject> events;

    public WSEventHandler(List<SObject> events) {
        this.events = events;
    }

    public virtual void handle() {
        List<SObject> anotherChunk = new List<SObject>();
        for (SObject event : events) {
            if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                WSAsyncJob.run(createJob(event));
            } else {
                anotherChunk.add(event);
            }
        }
        EventBus.publish(anotherChunk);
    }

    public abstract WSAsyncJob createJob(SObject event);
}
