public class WSHandlerWrapper {
    public final UpdateType updateType;
    public final String className;
    public final Map<String, Object> args;

    public WSHandlerWrapper(UpdateType updateType, String className, Map<String, Object> args) {
        validateHandlerClass(className);
        this.updateType = updateType;
        this.className = className;
        this.args = args == null ? new Map<String, Object>() : args;
    }

    public Boolean ofType(String type) {
        return updateType.name() == type;
    }

    private void validateHandlerClass(String handlerClassName) {
        Object handler = Type.forName(handlerClassName)?.newInstance();
        if (handler == null || !(handler instanceof WSMessageHandler)) {
            throw new TypeException(
                'The provided handler class name "' +
                handlerClassName +
                '" doesn\'t exist or it doesn\'t extend the WSMessageHandler class'
            );
        }
    }

    public enum UpdateType {
        Message,
        Error,
        Close
    }
}
