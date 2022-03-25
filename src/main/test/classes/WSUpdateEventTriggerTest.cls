@IsTest(IsParallel=true)
public class WSUpdateEventTriggerTest {
    @IsTest
    private static void oneIncomingMessageWithArgumentsTest() {
        String clientId = '33393376-1c9f-4997-a141-f8feaec0977a';
        String message = 'Hello World!';
        Map<String, Object> args = new Map<String, Object>{ 'arg1' => 1, 'arg2' => 2 };

        Test.startTest();
        EventBus.publish(prepareUpdateEvent(clientId, message, args));
        Test.getEventBus().deliver();
        Test.stopTest();

        List<Account> newAccounts = [SELECT Name, Description FROM Account];

        System.assert(!newAccounts.isEmpty(), 'Handler was not executed once');
        System.assertEquals(1, newAccounts.size(), 'There should be only one client');
        System.assertEquals(clientId, newAccounts.get(0).Name, 'Client ids do not match');
        Map<String, Object> actualArgs = (Map<String, Object>) JSON.deserializeUntyped(newAccounts.get(0).Description);
        System.assertEquals(args.size(), actualArgs.size(), 'Args count is not correct');
    }

    private static WSUpdate__e prepareUpdateEvent(String id, String message, Map<String, Object> args) {
        return new WSUpdate__e(
            ClientId__c = id,
            Messages__c = JSON.serialize(new List<String>{ message }),
            Type__c = WSHandlerWrapper.UpdateType.Message.name(),
            HandlerClassName__c = 'WSUpdateEventTriggerTest.MockUpdateHandler',
            Arguments__c = JSON.serialize(args)
        );
    }

    public class MockUpdateHandler extends WSMessageHandler {
        public override void handle(WSConnection connection, Map<String, Object> args) {
            insert new Account(Name = connection.getClientId(), Description = JSON.serialize(args));
        }
    }
}
