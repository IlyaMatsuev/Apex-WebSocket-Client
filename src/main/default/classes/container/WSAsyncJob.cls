public abstract class WSAsyncJob implements Queueable {
    public void execute(QueueableContext context) {
        execute();
    }

    public abstract void execute();

    public static void run(WSAsyncJob job) {
        if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(job);
        } else {
            throw new LimitException('The hobs limit has been exceeded');
        }
    }
}
