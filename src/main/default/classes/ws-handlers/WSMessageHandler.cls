// TODO: Maybe consider interface instead of abstract class?
global abstract class WSMessageHandler {
    global abstract void handle(WSConnection connection, Map<String, Object> args);
}
