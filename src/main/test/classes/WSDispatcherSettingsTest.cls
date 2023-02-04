@IsTest(IsParallel = true)
private class WSDispatcherSettingsTest {
    @IsTest
    private static void getEndpointPositiveTest() {
        String endpoint = 'https://fake.ws-dispatcher.com/ws';
        initSetting(endpoint, 30000);

        String result = WSDispatcherSettings.getEndpoint();

        System.assertEquals(endpoint, result, 'Did not receive the valid endpoint');
    }

    @IsTest
    private static void getEndpointNoValueTest() {
        Exception error;
        try {
            String result = WSDispatcherSettings.getEndpoint();
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null, 'No exception has been thrown');
        System.assert(error instanceof IllegalArgumentException, 'Invalid exception type');
    }

    @IsTest
    private static void getTimeoutPositiveTest() {
        Integer timeout = 50000;
        initSetting('https://fake.ws-dispatcher.com/ws', timeout);

        Integer result = WSDispatcherSettings.getTimeout();

        System.assertEquals(timeout, result, 'Did not receive the valid timeout');
    }

    @IsTest
    private static void getTimeoutNoValueTest() {
        Integer result = WSDispatcherSettings.getTimeout();
        System.assertEquals(WSDispatcherSettings.HTTP_DEFAULT_TIMEOUT, result, 'Did not receive the valid timeout');
    }

    @IsTest
    private static void getTimeoutInvalidValueTest() {
        initSetting('https://fake.ws-dispatcher.com/ws', 1000);

        Exception error;
        try {
            Integer result = WSDispatcherSettings.getTimeout();
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null, 'No exception has been thrown');
        System.assert(error instanceof IllegalArgumentException, 'Invalid exception type');
    }

    private static void initSetting(String endpoint, Integer timeout) {
        insert new WSDispatcherSetting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Timeout__c = timeout,
            Endpoint__c = endpoint
        );
    }
}
