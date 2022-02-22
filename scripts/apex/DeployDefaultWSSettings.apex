final Integer DEFAULT_TIMEOUT = 50000;
final String DEFAULT_DISPATCHER_ENDPOINT = 'https://ws-dispatcher.herokuapp.com/ws';

insert new WSDispatcherSetting__c(
    SetupOwnerId = UserInfo.getOrganizationId(),
    Timeout__c = DEFAULT_TIMEOUT,
    Endpoint__c = DEFAULT_DISPATCHER_ENDPOINT
);
