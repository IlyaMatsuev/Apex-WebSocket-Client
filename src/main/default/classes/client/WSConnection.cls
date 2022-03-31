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

    global String getClientId() {
        return clientId;
    }

    global List<String> getUpdates() {
        return messages;
    }

    global void send(String message) {
        WSResponsePayload response = WSDispatcherService.message(clientId, message);
        if (!response.success) {
            throw new ConnectionException('Failed to send a message: ' + response.firstMessage);
        }
    }

    global void close() {
        // TODO: If I close it from connection, should all close handlers be ran?
        // Also, need to cancel the listen job if it's still running
        WSResponsePayload response = WSDispatcherService.close(clientId);
        if (!response.success) {
            throw new ConnectionException('Failed to close the connection: ' + response.firstMessage);
        }
    }

    public class ConnectionException extends Exception {
    }
}
