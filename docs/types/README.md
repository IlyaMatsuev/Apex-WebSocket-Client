# Type Definitions

Here are only specified global Apex types that are supposed to be used by a user as part of this package.

### Classes

-   [WSClient](#wsclient)
-   [WSConnection](#wsconnection)

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

`void send(String message)` - Sends message to the WebSocket server.

`void close()` - Closes the WebSocket connection.

---

### IWSMessageHandler

Implementation of this interface is needed for class to become a handler that can be used for the [`WSClient`](#wsclient).

`void handle(WSConnection connection, Map<String, Object> args)` - Will be called whenever there is a message, error, or closing request coming from the WebSocket server.
