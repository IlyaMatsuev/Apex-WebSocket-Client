/**
 * @description The static class-wrapper under the `WSDispatcherSetting__c` custom setting. Allows to change the `ws-dispatcher` endpoint and timeout in the runtime, without updating the existing settings
 */
global class WSDispatcherSettings {
    /**
     * @description Max possible request timeout
     */
    global static final Integer HTTP_MAX_TIMEOUT = 120000;
    /**
     * @description Min possible request timeout
     */
    global static final Integer HTTP_MIN_TIMEOUT = 5000;
    /**
     * @description Default request timeout
     */
    global static final Integer HTTP_DEFAULT_TIMEOUT = 30000;

    private static WSDispatcherSetting__c settings = WSDispatcherSetting__c.getOrgDefaults();

    private WSDispatcherSettings() {}

    /**
     * @description Returns the endpoint value set in the custom setting or manually during the transaction
     * @throws IllegalArgumentException If the value was not set before calling
     * @return The endpoint value
     */
    global static String getEndpoint() {
        return setEndpoint(settings.Endpoint__c);
    }

    /**
     * @description Sets the endpoint value manually until the end of the transaction
     * @throws IllegalArgumentException If the provided value is blank was not set before calling
     * @return The new endpoint value
     */
    global static String setEndpoint(String endpoint) {
        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('No endpoint has been provided');
        }
        return settings.Endpoint__c = endpoint;
    }

    /**
     * @description Returns the timeout value set in the custom setting or manually during the transaction
     * @throws IllegalArgumentException If the value was less than `HTTP_MIN_TIMEOUT` or more than `HTTP_MAX_TIMEOUT`
     * @return The timeout value
     */
    global static Integer getTimeout() {
        return setTimeout(settings.Timeout__c?.intValue());
    }

    /**
     * @description Sets the timeout value manually until the end of the transaction
     * @throws IllegalArgumentException If the provided value is less than `HTTP_MIN_TIMEOUT` or more than `HTTP_MAX_TIMEOUT`
     * @return The new timeout value
     */
    global static Integer setTimeout(Integer timeout) {
        if (timeout == null) {
            System.debug(LoggingLevel.WARN, 'No timeout has been provided. Consider using default timeout');
            return (settings.Timeout__c = HTTP_DEFAULT_TIMEOUT).intValue();
        } else if (timeout < HTTP_MIN_TIMEOUT || timeout > HTTP_MAX_TIMEOUT) {
            throw new IllegalArgumentException(
                'Request timeout should be in range from ' +
                HTTP_MIN_TIMEOUT +
                ' to ' +
                HTTP_MAX_TIMEOUT +
                ' milliseconds'
            );
        }
        return (settings.Timeout__c = timeout).intValue();
    }
}
