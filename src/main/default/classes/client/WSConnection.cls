/**
 * @description This class represents the WebSocket connection.
 */
global class WSConnection {
    private final String clientId;
    private List<String> messages;
    private Boolean closed = false;

    /**
     * @description Creates a new connection instance referencing the existing connection with the provided client id
     * @param clientId The temporary WebSocket client id
     */
    global WSConnection(String clientId) {
        this(clientId, new List<String>());
    }

    public WSConnection(String clientId, List<String> messages) {
        this.clientId = clientId;
        this.messages = messages;
    }

    /**
     * @description Returns temporary WebSocket client id used to communicate to the WebSocket server
     * @return Temporary WebSocket client id in UUID format
     */
    global String getClientId() {
        return clientId;
    }

    /**
     * @description Returns new incoming messages from the WebSocket server
     * @return One or more incoming messages from the WebSocket server
     */
    global List<String> getUpdates() {
        return messages;
    }

    /**
     * @description Checks if the connectoin has been already closed
     * @return `true` if the connection has been closed by `close()` method or by the server. Otherwise `false`
     */
    global Boolean isClosed() {
        return closed;
    }

    /**
     * @description Sends message to the WebSocket server
     * @param message The text message to send
     * @throws ConnectionException If the message wasn't sent successfully
     */
    global void send(String message) {
        // TODO: Don't allow to send again if the connection is closed
        WSResponsePayload response = WSDispatcherService.message(clientId, message);
        if (!response.success) {
            throw new ConnectionException('Failed to send a message: ' + response.firstMessage);
        }
    }

    /**
     * @description Synchronously listens to the updates from the WebSocket server
     * @throws ConnectionException If the listening to the WebSocket server failed
     * @return `true` if successfully received an update from the WebSocket server. `false` if the timeout response has been returned
     */
    global Boolean listen() {
        // TODO: Don't allow to listen again if the connection is closed
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

    /**
     * @description Closes the WebSocket connection
     * @throws ConnectionException If the closing request failed
     */
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

    public class ConnectionException extends Exception {}
}
