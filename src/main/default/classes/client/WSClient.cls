/**
 * @description This class is used to register message handlers and create a connection to the WebSocket server
 */
global class WSClient {
    private final List<WSHandlerWrapper> handlers = new List<WSHandlerWrapper>();

    /**
     * @description Registers a new message handler by providing class type
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when a message is received from the WebSocket server
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onMessage(Type handlerClassType) {
        return onMessage(handlerClassType, null);
    }

    /**
     * @description Registers a new message handler by providing class type and args to be passed
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when a message is received from the WebSocket server
     * @param args A generic collection of arguments that will be passed to the handler
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onMessage(Type handlerClassType, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Message, handlerClassType, args);
    }

    /**
     * @description Registers a new error handler by providing class type
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when an error is received from the WebSocket server
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onError(Type handlerClassType) {
        return onError(handlerClassType, null);
    }

    /**
     * @description Registers a new error handler by providing class type and args to be passed
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when an error is received from the WebSocket server
     * @param args A generic collection of arguments that will be passed to the handler
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onError(Type handlerClassType, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Error, handlerClassType, args);
    }

    /**
     * @description Registers a new close handler by providing class type
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when the WebSocket connection is closed
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onClose(Type handlerClassType) {
        return onClose(handlerClassType, null);
    }

    /**
     * @description Registers a new close handler by providing class type
     * @param handlerClassType The Apex class type that implements the `IWSMessageHandler` interface. This handler will be called when the WebSocket connection is closed
     * @param args A generic collection of arguments that will be passed to the handler
     * @throws TypeException If the provided Apex type doesn't implement the `IWSMessageHandler` interface
     * @return The current instance of the client
     */
    global WSClient onClose(Type handlerClassType, Map<String, Object> args) {
        return onEvent(WSHandlerWrapper.EventType.Close, handlerClassType, args);
    }

    /**
     * @description Establishes a connection to the WebSocket server by the provided WebSocket URL
     * @param endpoint The websocket server endpoint
     * @throws ConnectionException If the websocket failed to connect to the server
     * @return The new instance of the `WSConnection`
     */
    global WSConnection connect(String endpoint) {
        return connect(endpoint, null);
    }

    /**
     * @description Establishes a connection to the WebSocket server by the provided WebSocket URL and protocol name
     * @param endpoint The websocket server endpoint
     * @param protocol The websocket protocol to be used for connection
     * @throws ConnectionException If the websocket failed to connect to the server
     * @return The new instance of the `WSConnection`
     */
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

    private WSClient onEvent(WSHandlerWrapper.EventType handlerType, Type handlerClassType, Map<String, Object> args) {
        handlers.add(new WSHandlerWrapper(handlerType, handlerClassType, args));
        return this;
    }
}
