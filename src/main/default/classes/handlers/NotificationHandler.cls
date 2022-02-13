public class NotificationHandler {
    private final NotificationType type;
    private final String className;
    private final Map<String, Object> args;

    public NotificationHandler(NotificationType type, String className, Map<String, Object> args) {
        this.type = type;
        this.className = className;
        this.args = args == null ? new Map<String, Object>() : args;
    }

    public Boolean ofType(String typeName) {
        try {
            return type == NotificationType.valueOf(typeName);
        } catch (NoSuchElementException ex) {
            return false;
        }
    }

    public WSUpdate__e toEvent() {
        return new WSUpdate__e(Type__c = type, HandlerClassName__c = className, Arguments__c = JSON.serialize(args));
    }

    public enum NotificationType {
        Message,
        Error,
        Close
    }
}
