public class WSDispatcherSettings {
    public static final Integer HTTP_MAX_TIMEOUT = 120000;
    public static final Integer CPU_TIME_SCOPE = 3000;

    @TestVisible
    private static WSDispatcherSetting__c settings = WSDispatcherSetting__c.getOrgDefaults();

    public static String getEndpoint() {
        String settingValue = settings.Endpoint__c;
        if (String.isBlank(settingValue)) {
            throw new CalloutException('No endpoint has been provided in the WS Dispatcher Settings');
        }
        return settingValue;
    }

    public static Integer getTimeout() {
        Integer settingValue = settings.Timeout__c?.intValue();
        if (settingValue == null || settingValue > HTTP_MAX_TIMEOUT) {
            System.debug(
                LoggingLevel.WARN,
                'No timeout has been specified in the WS Dispatcher Settings. Consider using max timeout'
            );
            settingValue = HTTP_MAX_TIMEOUT;
        }
        return settingValue;
    }
}
