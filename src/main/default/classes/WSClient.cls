global class WSClient {
    // global void onMessage(MessageHandler handler) {
    // }

    // global void onClose(CloseHandler handler) {
    // }

    global Boolean connect(String endpoint) {
        return connect(endpoint, null);
    }

    global Boolean connect(String endpoint, String protocol) {
        ResponsePayload response = WSRedirectorService.connect(endpoint, protocol);

        if (!response.isSuccess()) {
            return false;
        }

        WSRedirectorService.listen(response.clientId);

        return true;
    }
}
