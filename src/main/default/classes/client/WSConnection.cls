global class WSConnection {
    private final String clientId;
    private List<String> messages;
    private Boolean closed = false;

    global WSConnection(String clientId) {
        this(clientId, new List<String>());
    }

    public WSConnection(String clientId, List<String> messages) {
        this.clientId = clientId;
        this.messages = messages;
    }

    global String getClientId() {
        return clientId;
    }

    global List<String> getUpdates() {
        return messages;
    }

    global Boolean isClosed() {
        return closed;
    }

    // TODO: Don't allow to send again if the connection is closed
    global void send(String message) {
        WSResponsePayload response = WSDispatcherService.message(clientId, message);
        if (!response.success) {
            throw new ConnectionException('Failed to send a message: ' + response.firstMessage);
        }
    }

    // TODO: Don't allow to listen again if the connection is closed
    global Boolean listen() {
        WSResponsePayload response = WSDispatcherService.listen(clientId);
        if (!response.success) {
            throw new ConnectionException('Failed to listen sync: ' + response.firstMessage);
        }
        if (response.event == WSResponsePayload.ResponseEvent.Close) {
            closed = true;
        }
        if (response.event != WSResponsePayload.ResponseEvent.Timeout) {
            messages = response.messages;
        }
        return response.event != WSResponsePayload.ResponseEvent.Timeout;
    }

    global void close() {
        if (closed) {
            System.debug(LoggingLevel.WARN, 'The connection is already closed');
            return;
        }
        WSResponsePayload response = WSDispatcherService.close(clientId);
        if (!response.success) {
            throw new ConnectionException('Failed to close the connection: ' + response.firstMessage);
        }
        closed = true;
    }

    global class ConnectionException extends Exception {}
}
