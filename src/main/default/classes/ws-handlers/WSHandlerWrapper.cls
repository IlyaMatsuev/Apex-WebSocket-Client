public class WSHandlerWrapper {
    public final EventType eventType;
    public final String className;
    public final Map<String, Object> args;

    public WSHandlerWrapper(EventType eventType, Type classType, Map<String, Object> args) {
        validateHandlerClass(classType);
        this.eventType = eventType;
        this.className = classType.getName();
        this.args = args == null ? new Map<String, Object>() : args;
    }

    public Boolean ofType(String type) {
        return eventType.name() == type;
    }

    private void validateHandlerClass(Type handlerClassType) {
        Object handler = handlerClassType?.newInstance();
        if (handler == null || !(handler instanceof IWSMessageHandler)) {
            throw new TypeException(
                'The provided handler class "' +
                handlerClassType?.getName() +
                '" doesn\'t exist or it doesn\'t implement the IWSMessageHandler interface'
            );
        }
    }

    public enum EventType {
        Message,
        Error,
        Close
    }
}
