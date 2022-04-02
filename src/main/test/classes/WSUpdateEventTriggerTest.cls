@IsTest(IsParallel=true)
public class WSUpdateEventTriggerTest {
    private static final String CLIENT_ID = '33393376-1c9f-4997-a141-f8feaec0977a';

    @IsTest
    private static void oneIncomingMessageWithArgumentsTest() {
        String clientId = '33393376-1c9f-4997-a141-f8feaec0977a';
        String message = 'Hello World!';
        Map<String, Object> args = new Map<String, Object>{ 'arg1' => 1, 'arg2' => 2 };

        Test.startTest();
        EventBus.publish(prepareUpdateEvent(CLIENT_ID, message, args));
        Test.getEventBus().deliver();
        Test.stopTest();

        List<Account> newAccounts = [SELECT Name, Description FROM Account];

        System.assert(!newAccounts.isEmpty(), 'Handler was not executed once');
        System.assertEquals(1, newAccounts.size(), 'There should be only one client');
        System.assertEquals(CLIENT_ID, newAccounts.get(0).Name, 'Client ids do not match');
        Map<String, Object> actualArgs = (Map<String, Object>) JSON.deserializeUntyped(newAccounts.get(0).Description);
        System.assertEquals(args.size(), actualArgs.size(), 'Args count is not correct');
    }

    @IsTest
    private static void multipleIncomingMessagesTest() {
        Test.startTest();
        // Create 60 events and only 50 of them will be executed in the current transaction
        EventBus.publish(prepareUpdateEvents(CLIENT_ID, 'Hello', 60));
        Test.getEventBus().deliver();
        Test.stopTest();

        List<Account> newAccounts = [SELECT Name, Description FROM Account];

        System.assert(!newAccounts.isEmpty(), 'Handler was not executed once');
        System.assertEquals(
            Limits.getLimitQueueableJobs(),
            newAccounts.size(),
            'Handler should have been called ' +
            Limits.getLimitQueueableJobs() +
            ' times'
        );
    }

    private static List<WSUpdateEvent__e> prepareUpdateEvents(String id, String message, Integer count) {
        List<WSUpdateEvent__e> events = new List<WSUpdateEvent__e>();
        for (Integer i = 0; i < count; i++) {
            events.add(prepareUpdateEvent(id, message + i, null));
        }
        return events;
    }

    private static WSUpdateEvent__e prepareUpdateEvent(String id, String message, Map<String, Object> args) {
        return new WSUpdateEvent__e(
            ClientId__c = id,
            Messages__c = JSON.serialize(new List<String>{ message }),
            HandlerClassName__c = 'WSUpdateEventTriggerTest.MockUpdateHandler',
            Arguments__c = JSON.serialize(args)
        );
    }

    public class MockUpdateHandler implements WSIMessageHandler {
        public void handle(WSConnection connection, Map<String, Object> args) {
            insert new Account(Name = connection.getClientId(), Description = JSON.serialize(args));
        }
    }
}
