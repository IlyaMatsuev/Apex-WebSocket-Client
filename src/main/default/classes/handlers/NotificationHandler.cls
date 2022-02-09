global abstract class NotificationHandler {

    private final Type handlerType;
    private final Object[] args;

    global NotificationHandler(Type handlerType) {
        this(handlerType, null);
    }

    global NotificationHandler(Type handlerType, Object[] args) {
        this.handlerType = handlerType;
        this.args = args;
    }

    global abstract void handle();
}
