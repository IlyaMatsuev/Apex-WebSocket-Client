@IsTest
public class WSUpdateHandlerMock implements IWSMessageHandler {
    public void handle(WSConnection connection, Map<String, Object> args) {
        if (args.get('insertData') == true) {
            insert new Account(Name = connection.getClientId(), Description = JSON.serialize(args));
        }
    }
}
