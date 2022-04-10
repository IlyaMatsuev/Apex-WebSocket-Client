# Examples

## Exchange Greetings

This is a simple example when you open a connection, you send a message and the server responds to you back.

First, we need to write a message handler that will show the server's message:

```java
public class SayHiBackMessageHandler implements IWSMessageHandler {
    public void handle(WSConnection connection, Map<String, Object> args) {
        // Don't forget to enable Debug Logs for Automated Process
        System.debug('Received: ' + connection.getUpdates().get(0));

        connection.close();
    }
}
```

Now, we can create the connection and initiate messaging. Execute the following in the Anonymous window:

```java
WSClient client = new WSClient();
client.onMessage(SayHiBackMessageHandler.class);

// Provide your WebSocket server URL
WSConnection connection = client.connect('wss://some-ws-endpoint.com');

connection.send('Hello Wolrd!');
```

## Closing An Existing Connection

You can close the existing connection via the `WSConnection` class instance. You can create one if you know the client id:

```java
WSClient client = new WSClient();

// Some code here...

WSConnection connection = client.connect('wss://some-ws-endpoint.com');

// You'd want to save the created client id somewhere if you wish to access this connection somewhere out of handlers classes later
System.debug(connection.getCLientId());
```

Then you can use this client id to close the connection:

```java
String clientId = '...';
WSConnection connection = new WSConnection(clientId);
connection.close();
```
