# Apex WebSocket Client

[![Scratch Org CI](https://github.com/IlyaMatsuev/Apex-WebSocket-Client/actions/workflows/scratch-org-ci.yml/badge.svg?branch=main)](https://github.com/IlyaMatsuev/Apex-WebSocket-Client/actions/workflows/scratch-org-ci.yml)
[![Test Coverage](https://codecov.io/gh/IlyaMatsuev/Apex-WebSocket-Client/branch/main/graph/badge.svg?token=PSRCUDWM3P)](https://codecov.io/gh/IlyaMatsuev/Apex-WebSocket-Client)

Salesforce Apex library that is aimed to provide support for the WebSocket protocol. Which can be used directly from Apex runtime (not only via LWC JS).

Of course, there is no native support for WebSocket in Apex yet. This project uses an external server that redirects HTTP requests as WebSocket messages.

## Overview

To handle WebSocket events you need to create a handler class that is going to handle incoming messages, errors, or connection closing:

```java
public class WebSocketMessageHandler implements IWSMessageHandler {
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
// Connect to the WebSocket server and receive the connection object
WSConnection connection = client.connect('wss://some-ws-endpoint.com');
// With the connection object we can send a new message or close the connection
connection.send('Hello World!');
```

For more examples, please refer to [here](docs/examples).

**Be aware, that this package uses a lot of Platform Events and Queueable Apex jobs to make things work. It can affect your organization's [governor limits](https://developer.salesforce.com/docs/atlas.en-us.234.0.platform_events.meta/platform_events/platform_event_limits.htm).**  
_Let's say we receive a new message every 10 seconds. For a minute of an established connection, it submits approximately 2-4 Queueable Apex jobs and fires 6-18 Platform Events (depending on the amount of registered handlers)._

## Installation

### From Unmanaged Package

You can just install the package by the link on a [sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001zNZfQAM) or [dev org](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001zNZfQAM).

If you prefer using salesforce CLI you can run:

```
sfdx force:package:install -p 04t5Y000001zNZfQAM -w 10 -b 10 -u <username>
```

### From Source

You can also install the package with the automated scripts: [`pkg-deploy.sh`](scripts/pkg-deploy.sh) and [`pkg-from-scratch.sh`](scripts/pkg-from-scratch.sh).  
First is for deploying changes to the existing org.

```
./scripts/pkg-deploy.sh <username_or_alias>
```

Second is for creating a new configured scratch org.

```
./scripts/pkg-from-scratch.sh <devhub_username_or_alias> <new_scratch_org_alias>
```

## Configuration

The library can be used as it is without any additional configuration, or it can be used with your own server running (which is recommended). For more details about how to run your server instance visit [this page](src/ws-dispatcher).

Also, don't forget to assign the `ApexWSClientUser` permission set to the necessary users and update the [`WSDispatcherSetting__c`](docs/README.md#wsdispatchersettingc) custom settings.

## Documentation

For more detailed information about the content of the repository and sfdx package, please visit [docs folder](docs).

## Questions

If you have any questions you can start a discussion.  
If you think something works not as expected or you want to request a new feature, you can create an issue with the appropriate template selected.

## Contributing

Pull requests are welcome.  
For major changes, please open an issue first to discuss what you would like to change.  
Please make sure to update tests as appropriate.

## License

[MIT](LICENSE)
