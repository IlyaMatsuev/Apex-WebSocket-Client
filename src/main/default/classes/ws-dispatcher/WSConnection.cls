global class WSConnection {
    private final String clientId;
    private final List<String> messages;

    public WSConnection(String clientId) {
        this(clientId, new List<String>());
    }

    public WSConnection(String clientId, List<String> messages) {
        this.clientId = clientId;
        this.messages = messages;
    }

    global List<String> getUpdates() {
        return messages;
    }

    global void send(String message) {
        ResponsePayload response = WSDispatcherService.message(clientId, message);
        if (!response.isSuccess()) {
            throw new ConnectionException('Failed to send a message: ' + response.getFirstMessage());
        }
    }

    global void close() {
        ResponsePayload response = WSDispatcherService.close(clientId);
        if (!response.isSuccess()) {
            throw new ConnectionException('Failed to close the connection: ' + response.getFirstMessage());
        }
    }

    global class ConnectionException extends Exception {
    }
}
