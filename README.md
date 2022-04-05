# Apex WebSocket Client

[comment]: # 'TODO: Some badges here'

Salesforce Apex library that is aimed to provide support for the WebSocket protocol. Which can be used directly from Apex runtime (not only via LWC JS).

Of course there is no native support for WebSocket in Apex yet. This project uses external server which redirects HTTP requests as WebSocket messages.

The source code and some tips regarding the server maintenance can be found [here](src/ws-dispatcher).

## Overview

In order to handle WebSocket events you need to create a handler class that is going to handle incoming messages, errors or connection closing:

```java
public class WebSocketMessageHandler implements WSIMessageHandler {
    public void handle(WSConnection connection, Map<String, Object> args) {
        // Get the new incoming messages (if there are any)
        List<String> newMessages = connection.getUpdates();

        // Send a message back to the WebSocket server
        connection.send('Message back!');

        // We can also request closing connection if we need to
        //connection.close();
    }
}
```

This is how you connect to the WebSocket server:

```java
WSClient client = new WSClient();
// Register onMessage event handler
client.onMessage(WebSocketMessageHandler.class);
// We also can set error handler if something goes wrong on the other side
client.onError(WebSocketMessageHandler.class);
// And we can register a handler that will be called when the connection is closed
client.onClose(WebSocketMessageHandler.class);
// Finally, we connect to the WebSocket server and receive the connection object
WSConnection connection = client.connect('wss://some-ws-endpoint.com');
// With the connection object we can send a new message or close the connection
connection.send('Hello World!');
connection.close();
```

For more examples, please refer [here](docs/examples).

**Be aware, that this package uses a lot of Platform Events and Queueable Apex jobs in order to make things work. It can affect your org's [governor limits](https://developer.salesforce.com/docs/atlas.en-us.234.0.platform_events.meta/platform_events/platform_event_limits.htm)**  
_Let's say we receive a new message every 10 seconds. For a minute of established connection it submits aproximately 2-4 Queueable Apex jobs and fires 6-18 Platform Events (depending on the amount of registered handlers)._

## Installation

### From Unmanaged Package

You can just install the package by the link on a [sandbox](http://test.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001wLvEQAU) or [dev org](http://login.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001wLvEQAU).

If you prefer using salesforce CLI you can run:

```
sfdx force:package:install -p ws-apex-client -w 10 -b 10 -u <username>
```

### From Source

You can also install the package with the automated scripts: [`pkg-deploy.sh`](scripts/pkg-deploy.sh) and [`pkg-from-scratch.sh`](scripts/pkg-from-scratch.sh).  
First is for deploying changes to the existing org.

```
./scripts/pkg-deploy.sh <username_or_alias>
```

Second is for creating a new configured scratch org.

```
./scripts/pkg-from-scratch.sh <devhub_username_or_alias> <new_scratch_org__alias>
```

## Configuration

The library can be used as it is without any additional configuration, or it can be used with your own server running (which is recommended). For more details about how to run your own server instance [visit page](src/ws-dispatcher).

Also, don't forget to assign the `ApexWSClientUser` permission set to the necessary users and update `WSDispatcherSetting__c` custom settings.

[comment]: # 'TODO: Add link to the WSDispatcherSetting documentation'

## Documentation

For more detailed information about the content of the repository and sfdx package, please visit [docs folder](docs).

Deployment of the external server is described [here](src/ws-dispatcher).

## Questions

If you have any questions you can start a discussion.  
If you think something works not as expected or you want to request a new feature, you can create an issue with the appropriate template selected.

## Contributing

Pull requests are welcome.  
For major changes, please open an issue first to discuss what you would like to change.  
Please make sure to update tests as appropriate.

## License

[MIT](LICENSE)
