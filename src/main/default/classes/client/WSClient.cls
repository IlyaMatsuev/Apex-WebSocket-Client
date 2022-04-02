global class WSClient {
    private final List<WSHandlerWrapper> handlers = new List<WSHandlerWrapper>();

    global WSClient onMessage(Type handlerClassType) {
        return onMessage(handlerClassType, null);
    }

    global WSClient onMessage(String handlerClassName) {
        return onMessage(handlerClassName, null);
    }

    global WSClient onMessage(Type handlerClassType, Map<String, Object> args) {
        return onMessage(handlerClassType.getName(), args);
    }

    global WSClient onMessage(String handlerClassName, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Message, handlerClassName, args);
    }

    global WSClient onError(Type handlerClassType) {
        return onError(handlerClassType, null);
    }

    global WSClient onError(String handlerClassName) {
        return onError(handlerClassName, null);
    }

    global WSClient onError(Type handlerClassType, Map<String, Object> args) {
        return onError(handlerClassType.getName(), args);
    }

    global WSClient onError(String handlerClassName, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Error, handlerClassName, args);
    }

    global WSClient onClose(Type handlerClassType) {
        return onClose(handlerClassType, null);
    }

    global WSClient onClose(String handlerClassName) {
        return onClose(handlerClassName, null);
    }

    global WSClient onClose(Type handlerClassType, Map<String, Object> args) {
        return onClose(handlerClassType.getName(), args);
    }

    global WSClient onClose(String handlerClassName, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Close, handlerClassName, args);
    }

    global WSConnection connect(String endpoint) {
        return connect(endpoint, null);
    }

    global WSConnection connect(String endpoint, String protocol) {
        WSResponsePayload response = WSDispatcherService.connect(endpoint, protocol);
        if (!response.success) {
            throw new WSConnection.ConnectionException('Failed to connect: ' + response.firstMessage);
        }
        if (!handlers.isEmpty()) {
            WSDispatcherService.listenAsync(response.clientId, handlers);
        }
        return new WSConnection(response.clientId);
    }

    private WSClient onEvent(
        WSHandlerWrapper.EventType handlerType,
        String handlerClassName,
        Map<String, Object> args
    ) {
        handlers.add(new WSHandlerWrapper(handlerType, handlerClassName, args));
        return this;
    }
}
