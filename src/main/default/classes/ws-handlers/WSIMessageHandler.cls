global interface WSIMessageHandler {
    void handle(WSConnection connection, Map<String, Object> args);
}
