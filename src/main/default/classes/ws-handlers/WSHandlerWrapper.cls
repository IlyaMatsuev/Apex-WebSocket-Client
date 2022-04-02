public class WSHandlerWrapper {
    public final EventType eventType;
    public final String className;
    public final Map<String, Object> args;

    public WSHandlerWrapper(EventType eventType, String className, Map<String, Object> args) {
        validateHandlerClass(className);
        this.eventType = eventType;
        this.className = className;
        this.args = args == null ? new Map<String, Object>() : args;
    }

    public Boolean ofType(String type) {
        return eventType.name() == type;
    }

    private void validateHandlerClass(String handlerClassName) {
        Object handler = Type.forName(handlerClassName)?.newInstance();
        if (handler == null || !(handler instanceof WSIMessageHandler)) {
            throw new TypeException(
                'The provided handler class name "' +
                handlerClassName +
                '" doesn\'t exist or it doesn\'t implement the WSIMessageHandler interface'
            );
        }
    }

    public enum EventType {
        Message,
        Error,
        Close
    }
}
