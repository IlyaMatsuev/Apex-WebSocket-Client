global class WSConnection {
    private final String clientId;
    private final List<String> messages;

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
        // TODO: Call WSDispatcherService.listen(); if there are no messages
        return messages;
    }

    global void send(String message) {
        WSResponsePayload response = WSDispatcherService.message(clientId, message);
        if (!response.success) {
            throw new ConnectionException('Failed to send a message: ' + response.firstMessage);
        }
    }

    global void close() {
        WSResponsePayload response = WSDispatcherService.close(clientId);
        if (!response.success) {
            throw new ConnectionException('Failed to close the connection: ' + response.firstMessage);
        }
    }

    global class ConnectionException extends Exception {
    }
}
