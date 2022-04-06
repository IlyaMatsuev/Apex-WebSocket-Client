global interface IWSMessageHandler {
    void handle(WSConnection connection, Map<String, Object> args);
}
