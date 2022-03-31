public abstract class WSAsyncJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        execute();
    }

    public abstract void execute();

    public static void run(WSAsyncJob job) {
        System.enqueueJob(job);
    }
}
