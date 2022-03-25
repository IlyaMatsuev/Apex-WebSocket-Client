@IsTest(IsParallel=true)
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
        System.assertEquals(
            'Failed to send a message: Invalid client id',
            error.getMessage(),
            'Exception message is not correct'
        );
    }

    @IsTest
    private static void closeConnectionTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        new WSConnection(CLIENT_ID).close();
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
        System.assertEquals(
            'Failed to close the connection: Invalid client id',
            error.getMessage(),
            'Exception message is not correct'
        );
    }
}
