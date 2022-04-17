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
System.debug('Is closed? ' + connection.isClosed());
```

## Synchronously Listen To The Messages

You can listen to the messages from the WebSocket server right from the synchronously running Apex code.

Let's say you already have a client id:

```java
String clientId = '...';
WSConnection connection = new WSConnection(clientId);
Boolean receivedUpdates = connection.listen();
if (receivedUpdates) {
    // Here are our new received messages
    System.debug(connection.getUpdates());
} else {
    // If the returned value is false it means that you've reached the timeout response
}
```

It also can happen that the connection is closed. In this case, you would still receive `true` as the result and you have to check if the connection closed yourself:

```java
...
Boolean receivedUpdates = connection.listen();
if (receivedUpdates) {
    System.debug('Is closed? ' + connection.isClosed());
} else {
    // And again, if the returned value is false it means the connection is still alive
}
```
