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
        WSResponsePayload response = new WSDispatcherService().connect('wss://fake.ws.endpoint/', null);
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
        WSResponsePayload response = new WSDispatcherService().connect('wss://fake.ws.endpoint/', null);
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
        WSResponsePayload response = new WSDispatcherService().message(CLIENT_ID, 'Hello World!');
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
        WSResponsePayload response = new WSDispatcherService().message(CLIENT_ID, 'Hello World!');
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
        WSResponsePayload response = new WSDispatcherService().close(CLIENT_ID);
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
        WSResponsePayload response = new WSDispatcherService().close(CLIENT_ID);
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
    private static void listenCommandTimeoutAndCloseResponseTest() {
        MockEventPublisher eventPublisher = new MockEventPublisher();
        Test.setMock(
            HttpCalloutMock.class,
            new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Timeout, 'Timeout. Reconnect again')
        );
        Test.startTest();
        WSDispatcherService.eventPublisher = eventPublisher;
        new WSDispatcherService()
            .listen(
                CLIENT_ID,
                new List<WSHandlerWrapper>{
                    new WSHandlerWrapper(
                        WSHandlerWrapper.UpdateType.Close,
                        'WSDispatcherServiceTest.MockUpdateHandler',
                        null
                    )
                }
            );
        Test.stopTest();

        System.assertEquals(1, eventPublisher.updates.size(), 'There should be only one update event');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(0).ClientId__c, 'Client ids do not match');
        System.assertEquals(
            WSHandlerWrapper.UpdateType.Close.name(),
            eventPublisher.updates.get(0).Type__c,
            'Type should be "Close"'
        );
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
    private static void listenCommandMessageResponseTest() {
        String message = 'Hello World!';
        MockEventPublisher eventPublisher = new MockEventPublisher();
        Test.setMock(HttpCalloutMock.class, new WSDispatcherHttpMock(WSResponsePayload.ResponseEvent.Message, message));
        Test.startTest();
        WSDispatcherService.eventPublisher = eventPublisher;
        new WSDispatcherService()
            .listen(
                CLIENT_ID,
                new List<WSHandlerWrapper>{
                    new WSHandlerWrapper(
                        WSHandlerWrapper.UpdateType.Message,
                        'WSDispatcherServiceTest.MockUpdateHandler',
                        null
                    ),
                    new WSHandlerWrapper(
                        WSHandlerWrapper.UpdateType.Close,
                        'WSDispatcherServiceTest.MockUpdateHandler',
                        null
                    )
                }
            );
        Test.stopTest();

        System.assertEquals(2, eventPublisher.updates.size(), 'There should be two update events');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(0).ClientId__c, 'Client ids do not match');
        System.assertEquals(CLIENT_ID, eventPublisher.updates.get(1).ClientId__c, 'Client ids do not match');
        System.assertEquals(
            WSHandlerWrapper.UpdateType.Message.name(),
            eventPublisher.updates.get(0).Type__c,
            'Type should be "Message"'
        );
        System.assertEquals(
            WSHandlerWrapper.UpdateType.Close.name(),
            eventPublisher.updates.get(1).Type__c,
            'Type should be "Close"'
        );
        List<String> messages = new List<String>();
        messages.addAll((List<String>) JSON.deserialize(eventPublisher.updates.get(0).Messages__c, List<String>.class));
        messages.addAll((List<String>) JSON.deserialize(eventPublisher.updates.get(1).Messages__c, List<String>.class));
        System.assertEquals(2, messages.size(), 'There should be two messages');
        System.assertEquals(message, messages.get(0), 'Message is not correct');
        System.assertEquals('Connection closed', messages.get(1), 'Message is not correct');
    }

    @IsTest
    private static void listenCommandInvalidClientIdTest() {
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
            new WSDispatcherService().listen(CLIENT_ID, new List<WSHandlerWrapper>());
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
    private static void dispatcherSettingsAreNotSetTest() {
        WSDispatcherSettings.settings = new WSDispatcherSetting__c();
        String endpoint;
        Integer timeout;
        Exception error;
        Test.startTest();
        try {
            timeout = WSDispatcherSettings.getTimeout();
            endpoint = WSDispatcherSettings.getEndpoint();
        } catch (Exception ex) {
            error = ex;
        }
        Test.stopTest();

        System.assertEquals(WSDispatcherSettings.HTTP_MAX_TIMEOUT, timeout, 'Timeout should have become max value');
        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof CalloutException, 'Exception type is not correct');
        System.assertEquals(
            'No endpoint has been provided in the WS Dispatcher Settings',
            error.getMessage(),
            'Exception message is not correct'
        );
    }

    @IsTest
    private static void messageHandlerWithInvalidClassNameTest() {
        Exception error;
        try {
            new WSHandlerWrapper(WSHandlerWrapper.UpdateType.Message, 'FakeClassName', null);
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null, 'Exception should have been thrown');
        System.assert(error instanceof TypeException, 'Exception type is not correct');
        System.assertEquals(
            'The provided handler class name "FakeClassName" doesn\'t exist or it doesn\'t extend the WSMessageHandler class',
            error.getMessage(),
            'Exception message is not correct'
        );
    }

    @IsTest
    private static void eventPublisherTest() {
        // This test method is only needed for covering WSDispatcherService.EventPublisher class since there is no logic
        new WSDispatcherService.EventPublisher().publish(new List<WSUpdate__e>());
    }

    public class MockUpdateHandler extends WSMessageHandler {
        public override void handle(WSConnection connection, Map<String, Object> args) {
        }
    }

    private class MockEventPublisher extends WSDispatcherService.EventPublisher {
        public final List<WSUpdate__e> updates = new List<WSUpdate__e>();

        public override void publish(List<SObject> events) {
            updates.addAll((List<WSUpdate__e>) events);
        }
    }
}
