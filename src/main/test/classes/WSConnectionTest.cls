@IsTest(IsParallel = true)
private class WSConnectionTest {
    private static final String CLIENT_ID = 'eb3e9a51-f7a3-493b-b208-fae170374e8e';

    @TestSetup
    private static void init() {
        insert new WSDispatcherSetting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Timeout__c = 50000,
            Endpoint__c = 'https://fake.ws-dispatcher.com/ws'
        );
    }

    @IsTest
    private static void checkClientIdAndMessagesTest() {
        WSConnection connection = new WSConnection(CLIENT_ID);
        System.assert(connection.getUpdates().isEmpty(), 'There should be no updates');
        System.assertEquals(CLIENT_ID, connection.getClientId(), 'Client id is not correct');
    }

    @IsTest
    private static void sendMessageTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        new WSConnection(CLIENT_ID).send('Hello World!');
        System.assertEquals(1, Limits.getCallouts());
        Test.stopTest();
    }

    @IsTest
    private static void sendMessageWithInvalidClientIdTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Error, 'Invalid client id')
        );
        Exception error;
        Test.startTest();
        try {
            new WSConnection(CLIENT_ID).send('Hello World!');
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof WSConnection.ConnectionException, 'Exception type is not correct');
    }

    @IsTest
    private static void listenToUpdatesTest() {
        String responseMessage = 'Hello World!';
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Message, responseMessage)
        );
        WSConnection connection = new WSConnection(CLIENT_ID);
        Test.startTest();
        Boolean updatesReceived = connection.listen();
        List<String> messages = connection.getUpdates();
        Test.stopTest();

        System.assert(updatesReceived, 'The Timeout response received');
        System.assertEquals(1, messages.size(), 'There should be only one message');
        System.assertEquals(responseMessage, messages.get(0), 'Wrong response message');
    }

    @IsTest
    private static void listenToUpdatesWithTimeoutTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Timeout, 'Timeout. Reconnect again')
        );
        WSConnection connection = new WSConnection(CLIENT_ID);
        Test.startTest();
        Boolean updatesReceived = connection.listen();
        Test.stopTest();

        System.assert(!updatesReceived, 'The Timeout should be received');
        System.assert(connection.getUpdates().isEmpty(), 'There should be no messages');
    }

    @IsTest
    private static void listenToUpdatesWithClosingTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Close, 'Connection closed')
        );
        WSConnection connection = new WSConnection(CLIENT_ID);
        Test.startTest();
        Boolean updatesReceived = connection.listen();
        Test.stopTest();

        System.assert(updatesReceived, 'The Timeout response received');
        System.assert(connection.isClosed(), 'Connection should be closed');
        System.assertEquals(1, connection.getUpdates().size(), 'There should be one closing message');
    }

    @IsTest
    private static void listenToUpdatesWithInvalidClientIdTest() {
        String responseMessage = 'Hello World!';
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Error, 'Invalid client id')
        );
        Exception error;
        Test.startTest();
        try {
            new WSConnection(CLIENT_ID).listen();
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof WSConnection.ConnectionException, 'Exception type is not correct');
    }

    @IsTest
    private static void closeConnectionRepeatedlyTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        WSConnection connection = new WSConnection(CLIENT_ID);
        Test.startTest();
        connection.close();
        connection.close();
        connection.close();
        System.assert(connection.isClosed(), 'Connection should be closed');
        System.assertEquals(1, Limits.getCallouts(), 'Callout has been sent more than once');
        Test.stopTest();
    }

    @IsTest
    private static void closeConnectionWithInvalidClientIdTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Error, 'Invalid client id')
        );
        Exception error;
        Test.startTest();
        try {
            new WSConnection(CLIENT_ID).close();
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof WSConnection.ConnectionException, 'Exception type is not correct');
    }
}
