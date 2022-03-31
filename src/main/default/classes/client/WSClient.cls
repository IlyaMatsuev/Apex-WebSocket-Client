global class WSClient {
    private final List<WSHandlerWrapper> handlers = new List<WSHandlerWrapper>();

    global WSClient onMessage(String handlerClassName) {
        return onMessage(handlerClassName, null);
    }

    global WSClient onMessage(String handlerClassName, Map<String, Object> args) {
        handlers.add(new WSHandlerWrapper(WSHandlerWrapper.UpdateType.Message, handlerClassName, args));
        return this;
    }

    global WSClient onClose(String handlerClassName) {
        return onClose(handlerClassName, null);
    }

    global WSClient onClose(String handlerClassName, Map<String, Object> args) {
        handlers.add(new WSHandlerWrapper(WSHandlerWrapper.UpdateType.Close, handlerClassName, args));
        return this;
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
}
