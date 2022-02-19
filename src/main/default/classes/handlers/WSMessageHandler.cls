global abstract class WSMessageHandler {
    public WSMessageHandler() {
    }

    global abstract void handle(WSConnection connection, Map<String, Object> args);
}
