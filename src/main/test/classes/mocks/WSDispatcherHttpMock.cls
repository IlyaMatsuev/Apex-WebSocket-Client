@IsTest
public class WSDispatcherHttpMock implements HttpCalloutMock {
    private final WSResponsePayload.ResponseEvent responseEvent;
    private final String responseMessage;
    private final Exception calloutError;
    private static Boolean listenExecuted = false;

    public WSDispatcherHttpMock() {
        this(null, null);
    }

    public WSDispatcherHttpMock(Exception calloutError) {
        this.calloutError = calloutError;
    }

    public WSDispatcherHttpMock(WSResponsePayload.ResponseEvent responseEvent, String responseMessage) {
        this.responseEvent = responseEvent;
        this.responseMessage = responseMessage;
    }

    public HttpResponse respond(HttpRequest request) {
        if (calloutError != null) {
            throw calloutError;
        }

        Map<String, Object> untypedRequestPayload = (Map<String, Object>) JSON.deserializeUntyped(request.getBody());
        WSRequestPayload requestPayload = new WSRequestPayload(
            WSRequestPayload.RequestCommand.valueOf((String) untypedRequestPayload.get('command')),
            untypedRequestPayload
        );
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(getResponseObject(requestPayload)));
        return response;
    }

    private Map<String, Object> getResponseObject(WSRequestPayload request) {
        if (responseEvent == WSResponsePayload.ResponseEvent.Error) {
            return new Map<String, Object> { 'event' => 'error', 'messages' => new List<String> { responseMessage } };
        }

        switch on request.command {
            when Connect {
                return getResponseObject(generateUuid(), 'connect', 'Connection established');
            }
            when Listen {
                // Prevent recursive calling, send close event after
                if (listenExecuted) {
                    return getResponseObject(request.clientId, 'close', 'Connection closed');
                }
                if (!listenExecuted) {
                    listenExecuted = true;
                }
                return getResponseObject(request.clientId, responseEvent?.name()?.toLowerCase(), responseMessage);
            }
            when Message {
                return getResponseObject(request.clientId, 'message', 'The message has been sent');
            }
            when Close {
                return getResponseObject(request.clientId, 'close', 'Connection closed');
            }
            when else {
                throw new WSDispatcherHttpMockException('There is no such command: "' + request.command.name() + '"');
            }
        }
    }

    private Map<String, Object> getResponseObject(String clientId, String event, String message) {
        return new Map<String, Object> {
            'clientId' => clientId,
            'event' => event,
            'messages' => new List<String> { message }
        };
    }

    private String generateUuid() {
        String hex = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        return hex.substring(0, 8) +
            '-' +
            hex.substring(8, 12) +
            '-' +
            hex.substring(12, 16) +
            '-' +
            hex.substring(16, 20) +
            '-' +
            hex.substring(20);
    }

    private class WSDispatcherHttpMockException extends Exception {}
}
