@IsTest(IsParallel=true)
public class WSDispatcherServiceTest {
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
    private static void connectCommandTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.connect('wss://fake.ws.endpoint/', null);
        Test.stopTest();

        System.assert(String.isNotBlank(response.clientId), 'Client id should be set after connection');
        System.assertEquals('Connect', response.event.name(), '"Connect" event should be returned');
        System.assertEquals('Connection established', response.firstMessage, 'Response message is not correct');
    }

    @IsTest
    private static void connectCommandInvalidEndpointTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Error, 'Failed to connect: invalid address')
        );
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.connect('wss://fake.ws.endpoint/', null);
        Test.stopTest();

        System.assert(String.isBlank(response.clientId), 'Client id should not be returned');
        System.assert(!response.success, '"Error" event should be returned');
        System.assertEquals(
            'Failed to connect: invalid address',
            response.firstMessage,
            'Response message is not correct'
        );
    }

    @IsTest
    private static void messageCommandTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.message(CLIENT_ID, 'Hello World!');
        Test.stopTest();

        System.assertEquals(CLIENT_ID, response.clientId, 'Client id is not correct');
        System.assertEquals('Message', response.event.name(), '"Message" event should be returned');
        System.assertEquals('The message has been sent', response.firstMessage, 'Response message is not correct');
    }

    @IsTest
    private static void messageCommandInvalidClientIdTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(
                WSResponsePayload.ResponseEvent.Error,
                'Whether no client id has been provided or it\'s incorrect'
            )
        );
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.message(CLIENT_ID, 'Hello World!');
        Test.stopTest();

        System.assert(String.isBlank(response.clientId), 'Client id should not be returned');
        System.assertEquals('Error', response.event.name(), '"Error" event should be returned');
        System.assertEquals(
            'Whether no client id has been provided or it\'s incorrect',
            response.firstMessage,
            'Response message is not correct'
        );
    }

    @IsTest
    private static void closeCommandTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock());
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.close(CLIENT_ID);
        Test.stopTest();

        System.assertEquals(CLIENT_ID, response.clientId, 'Client id is not correct');
        System.assertEquals('Close', response.event.name(), '"Close" event should be returned');
        System.assertEquals('Connection closed', response.firstMessage, 'Response message is not correct');
    }

    @IsTest
    private static void closeCommandInvalidClientIdTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(
                WSResponsePayload.ResponseEvent.Error,
                'Whether no client id has been provided or it\'s incorrect'
            )
        );
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.close(CLIENT_ID);
        Test.stopTest();

        System.assert(String.isBlank(response.clientId), 'Client id should not be returned');
        System.assertEquals('Error', response.event.name(), '"Error" event should be returned');
        System.assertEquals(
            'Whether no client id has been provided or it\'s incorrect',
            response.firstMessage,
            'Response message is not correct'
        );
    }

    @IsTest
    private static void listenCommandWithMessageTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Message, 'Hello World!')
        );
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.listen(CLIENT_ID);
        Test.stopTest();

        System.assertEquals(CLIENT_ID, response.clientId, 'Client id is not correct');
        System.assertEquals('Message', response.event.name(), '"Message" event should be returned');
        System.assertEquals('Hello World!', response.firstMessage, 'Response message is not correct');
    }

    @IsTest
    private static void listenCommandWithCalloutTimeoutExceptionTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock(new CalloutException('Read timed out')));
        Test.startTest();
        WSResponsePayload response = WSDispatcherService.listen(CLIENT_ID);
        Test.stopTest();

        System.assertEquals(CLIENT_ID, response.clientId, 'Client id is not correct');
        System.assertEquals('Timeout', response.event.name(), '"Timeout" event should be returned');
        System.assertEquals('Timeout. Reconnect again', response.firstMessage, 'Response message is not correct');
    }

    @IsTest
    private static void listenCommandWithUnexpectedExceptionTest() {
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock(new NullPointerException()));
        Test.startTest();
        Exception error;
        try {
            WSDispatcherService.listen(CLIENT_ID);
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof NullPointerException, 'Exception type is not correct');
    }

    @IsTest
    private static void listenAsyncCommandTimeoutAndCloseResponseTest() {
        MockEventPublisher eventPublisher = new MockEventPublisher();
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Timeout, 'Timeout. Reconnect again')
        );
        Test.startTest();
        WSListenEventHandler.eventPublisher = eventPublisher;
        WSDispatcherService.listenAsync(
            CLIENT_ID,
            new List<WSHandlerWrapper>{
                new WSHandlerWrapper(
                    WSHandlerWrapper.EventType.Close,
                    WSDispatcherServiceTest.MockUpdateHandler.class,
                    null
                )
            }
        );
        Test.getEventBus().deliver();
        Test.stopTest();

        System.assertEquals(1, eventPublisher.updates.size(), 'There should be only one update event');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(0).ClientId__c, 'Client ids do not match');
        System.assertEquals(
            'WSDispatcherServiceTest.MockUpdateHandler',
            eventPublisher.updates.get(0).HandlerClassName__c,
            'Handler class name is not correct'
        );
        List<String> messages = (List<String>) JSON.deserialize(
            eventPublisher.updates.get(0).Messages__c,
            List<String>.class
        );
        System.assertEquals(1, messages.size(), 'There should be one message');
        System.assertEquals('Connection closed', messages.get(0), 'Message is not correct');
        Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(
            eventPublisher.updates.get(0).Arguments__c
        );
        System.assert(args.isEmpty(), 'Args should be empty');
    }

    @IsTest
    private static void listenAsyncCommandMessageResponseTest() {
        String message = 'Hello World!';
        MockEventPublisher eventPublisher = new MockEventPublisher();
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Message, message));
        Test.startTest();
        WSListenEventHandler.eventPublisher = eventPublisher;
        WSDispatcherService.listenAsync(
            CLIENT_ID,
            new List<WSHandlerWrapper>{
                new WSHandlerWrapper(
                    WSHandlerWrapper.EventType.Message,
                    WSDispatcherServiceTest.MockUpdateHandler.class,
                    null
                ),
                new WSHandlerWrapper(
                    WSHandlerWrapper.EventType.Close,
                    WSDispatcherServiceTest.MockUpdateHandler.class,
                    null
                )
            }
        );
        Test.getEventBus().deliver();
        Test.stopTest();

        System.assertEquals(2, eventPublisher.updates.size(), 'There should be two update events');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(0).ClientId__c, 'Client ids do not match');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(1).ClientId__c, 'Client ids do not match');
        List<String> messages = new List<String>();
        messages.addAll((List<String>) JSON.deserialize(eventPublisher.updates.get(0).Messages__c, List<String>.class));
        messages.addAll((List<String>) JSON.deserialize(eventPublisher.updates.get(1).Messages__c, List<String>.class));
        System.assertEquals(2, messages.size(), 'There should be two messages');
        System.assertEquals(message, messages.get(0), 'Message is not correct');
        System.assertEquals('Connection closed', messages.get(1), 'Message is not correct');
    }

    @IsTest
    private static void listenAsyncCommandInvalidClientIdTest() {
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(
                WSResponsePayload.ResponseEvent.Error,
                'Whether no client id has been provided or it\'s incorrect'
            )
        );
        Exception error;
        try {
            Test.startTest();
            WSDispatcherService.listenAsync(CLIENT_ID, new List<WSHandlerWrapper>());
            Test.getEventBus().deliver();
            Test.stopTest();
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof WSConnection.ConnectionException, 'Exception type is not correct');
        System.assertEquals(
            'Failed to listen: Whether no client id has been provided or it\'s incorrect',
            error.getMessage(),
            'Response message is not correct'
        );
    }

    @IsTest
    private static void messageHandlerWithInvalidClassTypeTest() {
        Exception error;
        try {
            new WSHandlerWrapper(WSHandlerWrapper.EventType.Message, null, null);
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof TypeException, 'Exception type is not correct');
        System.assertEquals(
            'The provided handler class "null" doesn\'t exist or it doesn\'t implement the IWSMessageHandler interface',
            error.getMessage(),
            'Exception message is not correct'
        );
    }

    @IsTest
    private static void eventPublisherTest() {
        // This test method is only needed for covering WSListenEventHandler.EventPublisher class since there is no logic
        new WSListenEventHandler.EventPublisher().publish(new List<WSListenEvent__e>());
    }

    public class MockUpdateHandler implements IWSMessageHandler {
        public void handle(WSConnection connection, Map<String, Object> args) {
        }
    }

    private class MockEventPublisher extends WSListenEventHandler.EventPublisher {
        public final List<WSUpdateEvent__e> updates = new List<WSUpdateEvent__e>();

        public override void publish(List<SObject> events) {
            updates.addAll((List<WSUpdateEvent__e>) events);
        }
    }
}
