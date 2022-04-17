# Type Definitions

Here are only specified global Apex types that are supposed to be used by a user as part of this package.

### Classes

-   [WSClient](#wsclient)
-   [WSConnection](#wsconnection)
-   [WSDispatcherSettings](#wsdispatchersettings)

### Interfaces

-   [IWSMessageHandler](#iwsmessagehandler)

---

### WSClient

This class is used to register message handlers and create a connection to the WebSocket server.

#### Methods

`WSClient onMessage(Type handlerClassType)` - Registers a new message handler by providing class type. This handler will be called when a message is received from the WebSocket server. Returns the current instance.

`WSClient onMessage(Type handlerClassType, Map<String, Object> args)` - Registers a new message handler by providing class type and arguments. This handler will be called with the arguments when a message is received from the WebSocket server. Returns the current instance.

`WSClient onError(Type handlerClassType)` - Registers a new error handler by providing class type. This handler will be called when an error is received from the WebSocket server. Returns the current instance.

`WSClient onError(Type handlerClassType, Map<String, Object> args)` - Registers a new error handler by providing class type and arguments. This handler will be called with the arguments when an error is received from the WebSocket server. Returns the current instance.

`WSClient onClose(Type handlerClassType)` - Registers a new close handler by providing class type. This handler will be called when the WebSocket connection is closed. Returns the current instance.

`WSClient onClose(Type handlerClassType, Map<String, Object> args)` - Registers a new close handler by providing class type and arguments. This handler will be called with the arguments when the WebSocket connection is closed. Returns the current instance.

`WSConnection connect(String endpoint)` - Establishes a connection to the WebSocket server by the provided WebSocket URL. Returns the instance of the [`WSConnection`](#wsconnection) class.

`WSConnection connect(String endpoint, String protocol)` - Establishes a connection to the WebSocket server by the provided WebSocket URL and protocol name. Returns the instance of the [`WSConnection`](#wsconnection) class.

---

### WSConnection

This class represents the WebSocket connection. Can be used to get new messages from the server, send messages back, or to close the connection.

#### Constructors

`WSConnection(String clientId)` - Creates a new connection instance referencing the existing connection with the provided client id.

#### Methods

`String getClientId()` - Returns temporary WebSocket client id used to communicate to the WebSocket server.

`List<String> getUpdates()` - Returns new incoming messages from the WebSocket server. Usually, it's only one message but if the server sends messages too quickly they are going to be delivered as a couple.

`Boolean isClosed()` - Returns `true` if the close response has been received for this connection instance earlier (e.g. with the method `close()` or `listen()`). Otherwise returns `false`.

`void send(String message)` - Sends message to the WebSocket server.

`Boolean listen()` - Synchronously listens to the updates from the WebSocket server. Returns `true` if it has successfully fetched new messages. Returns `false` if the timeout response has been returned from the server. Be careful using this method as it can hit your governor callout time limit (if you make a few of these calls for example). Maybe useful in pair with the [`WSDispatcherSettings.setTimeout(Integer timeout)`](#wsdispatchersettings) method.

`void close()` - Closes the WebSocket connection.

---

### IWSMessageHandler

Implementation of this interface is needed for class to become a handler that can be used for the [`WSClient`](#wsclient).

`void handle(WSConnection connection, Map<String, Object> args)` - Will be called whenever there is a message, error, or closing request coming from the WebSocket server.

---

### WSDispatcherSettings

This is the static class-wrapper under the [`WSDispatcherSetting__c`](../README.md#wsdispatchersettingc) custom setting. It allows you to change the `ws-dispatcher` endpoint and timeout in the runtime, without updating the existing settings.

#### Constants

`Integer HTTP_MAX_TIMEOUT = 120000` - The maximum value in milliseconds allowed for the callout timeout to be set. If you increase this value during the transaction you will get the exception. It's not recommended to use that high value for the timeout.

`Integer HTTP_MIN_TIMEOUT = 5000` - The minimum value in milliseconds allowed for the callout timeout to be set. It's not recommended to use that low value for the timeout since the application will generate too many events per minute and you are more likely to reach the governor limits.

`Integer HTTP_DEFAULT_TIMEOUT = 30000` - The default value in milliseconds is used for callouts if it was not set in the custom settings.

#### Methods

`String getEndpoint()` - Returns the endpoint value set in the custom setting or manually during the transaction. Throws the `IllegalArgumentException` exception if the value was not set before calling.

`String setEndpoint(String endpoint)` - Sets the endpoint value manually until the end of the transaction. This call doesn't update the custom setting. Throws the `IllegalArgumentException` exception if the provided value is `null`. Returns the set value.

`Integer getTimeout()` - Returns the timeout value set in the custom setting or manually during the transaction. If there is no value in the custom setting then it returns the default timeout (`HTTP_DEFAULT_TIMEOUT`). Throws the `IllegalArgumentException` exception if the value is less than `HTTP_MIN_TIMEOUT` or more than `HTTP_MAX_TIMEOUT`.

`Integer setTimeout(Integer timeout)` - Sets the timeout value manually until the end of the transaction. This call doesn't update the custom setting. If the provided value is `null` then it sets the default timeout (`HTTP_DEFAULT_TIMEOUT`). Throws the `IllegalArgumentException` exception if the provided value is less than `HTTP_MIN_TIMEOUT` or more than `HTTP_MAX_TIMEOUT`. Returns the set value.
