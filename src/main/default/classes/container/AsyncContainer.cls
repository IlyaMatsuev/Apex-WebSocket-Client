public class AsyncContainer {
    public static void run(IDelegate delegate) {
        if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new QueuableContainer(delegate));
        }
    }

    private class QueuableContainer implements Queueable {
        private final IDelegate delegate;

        public QueuableContainer(IDelegate delegate) {
            this.delegate = delegate;
        }

        public void execute(QueueableContext context) {
            delegate.run();
        }
    }

    public interface IDelegate {
        void run();
    }
}
