global class WSDispatcherSettings {
    global static final Integer HTTP_MAX_TIMEOUT = 120000;
    global static final Integer HTTP_MIN_TIMEOUT = 5000;
    global static final Integer HTTP_DEFAULT_TIMEOUT = 30000;
    public static final Integer CPU_TIME_SCOPE = 5000;

    private static WSDispatcherSetting__c settings = WSDispatcherSetting__c.getOrgDefaults();

    global static String getEndpoint() {
        return setEndpoint(settings.Endpoint__c);
    }

    global static String setEndpoint(String endpoint) {
        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('No endpoint has been provided');
        }
        return settings.Endpoint__c = endpoint;
    }

    global static Integer getTimeout() {
        return setTimeout(settings.Timeout__c?.intValue());
    }

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
