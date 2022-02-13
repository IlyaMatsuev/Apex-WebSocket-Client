global class WSClient {
    private final List<NotificationHandler> handlers = new List<NotificationHandler>();

    global void onMessage(String handlerClassName) {
        onMessage(handlerClassName, null);
    }

    global void onMessage(String handlerClassName, Map<String, Object> args) {
        handlers.add(new NotificationHandler(NotificationHandler.NotificationType.Message, handlerClassName, args));
    }

    global void onClose(String handlerClassName) {
        onClose(handlerClassName, null);
    }

    global void onClose(String handlerClassName, Map<String, Object> args) {
        handlers.add(new NotificationHandler(NotificationHandler.NotificationType.Close, handlerClassName, args));
    }

    global Boolean connect(String endpoint) {
        return connect(endpoint, null);
    }

    global Boolean connect(String endpoint, String protocol) {
        ResponsePayload response = WSDispatcherService.connect(endpoint, protocol);

        if (!response.isSuccess()) {
            return false;
        }

        WSDispatcherService.listen(response.clientId);

        return true;
    }
}
