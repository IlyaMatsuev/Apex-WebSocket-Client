@IsTest(IsParallel=true)
public class WSClientTest {
    @TestSetup
    private static void init() {
        insert new WSDispatcherSetting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Timeout__c = 50000,
            Endpoint__c = 'https://fake.ws-dispatcher.com/ws'
        );
    }

    @IsTest
    private static void connectWithNoHandlersAndJustMessageAndCloseTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        WSConnection connection = new WSClient().connect('wss://fake.ws.endpoint/');
        connection.send('Hello World!');
        connection.close();
        Test.stopTest();
    }

    @IsTest
    private static void connectFailedTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Error, 'Unable to connect')
        );
        Exception error;
        Test.startTest();
        try {
            new WSClient().connect('wss://fake.ws.endpoint/');
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof WSConnection.ConnectionException, 'Exception type is not correct');
        System.assertEquals(
            'Failed to connect: Unable to connect',
            error.getMessage(),
            'Exception message is not correct'
        );
    }

    @IsTest
    private static void connectWithMessageAndErrorAndCloseHandlersTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Message, 'Hello World!')
        );
        Test.startTest();
        WSConnection connection = new WSClient()
            .onMessage(WSClientTest.MockUpdateHandler.class)
            .onMessage(WSClientTest.MockUpdateHandler.class, new Map<String, Object>{ 'test' => 1 })
            .onError(WSClientTest.MockUpdateHandler.class)
            .onError(WSClientTest.MockUpdateHandler.class, new Map<String, Object>{ 'test' => 2 })
            .onClose(WSClientTest.MockUpdateHandler.class)
            .onClose(WSClientTest.MockUpdateHandler.class, new Map<String, Object>{ 'test' => 3 })
            .connect('wss://fake.ws.endpoint/');
        Test.getEventBus().deliver();
        Test.stopTest();
        // Right now there is no way to test this kind of scenario:
        // In this case we start Queueable job which publishes events and event trigger starts a new job
        // Even Test.startTest(), Test.startTest() and Test.getEventBus().deliver() don't work with this scenario
    }

    public class MockUpdateHandler implements IWSMessageHandler {
        public void handle(WSConnection connection, Map<String, Object> args) {
        }
    }
}
