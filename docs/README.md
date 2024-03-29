# Documentation

## Idea

The idea of the package is to provide an ability to establish a WebSocket connection right from Apex. It will be useful if you need to automate the WebSocket connection so that there is no UI available and you can't use JavaScript for this purpose.

To receive WebSocket updates you have to register a certain handler first. It can be onMessage, onError, or onClose handler. When you create a client instance and call the `connect()` method, it sends an HTTP request to the [`ws-dispatcher server`](../src/ws-dispatcher). `Ws-dispatcher` gets this request and opens a connection to the specified WebSocket endpoint. Apart from that, the `connect()` method also submits an Apex "Listen" job to fetch updates (messages, errors, or connection closing) from the `ws-dispatcher` by making additional HTTP calls. When a new message arrives, `ws-dispatcher` responds and redirects the message to Apex. The "Listen" job tries to create an instance of the handler class and call it. To avoid facing limits, this job continues to submit new child jobs until the connection is closed.

Take a look at the interaction diagrams below:

![Screenshot 2023-02-05 at 7 16 42 PM](https://user-images.githubusercontent.com/39780006/216837435-49d77ad9-aae2-4259-a3a9-c0500b2377c4.jpg)

![Screenshot 2023-02-05 at 7 20 05 PM](https://user-images.githubusercontent.com/39780006/216837593-0ff16aa0-0846-4fef-a2ac-2604fe1107d5.jpg)

![Screenshot 2023-02-05 at 7 14 50 PM](https://user-images.githubusercontent.com/39780006/216837342-de1293a8-43ea-47e8-afbe-49cbac3c4c10.jpg)

![Screenshot 2023-02-05 at 7 02 40 PM](https://user-images.githubusercontent.com/39780006/216837487-74b380eb-b301-4c95-8e9a-8dd361f19fd6.jpg)

## WS-Dispatcher

To check the `ws-dispatcher` code or set up your server instance, please visit [this page](../src/ws-dispatcher).

## Examples

Please take a look at the [examples folder](examples) to know what is possible to do with this package, and how to do it.

## Type Definitions

All classes available for use can be found [here](types). There is also a short description of their purpose and class members.

## Custom Settings

### WSDispatcherSetting\_\_c

Contains ws-dispatcher related settings.

-   `Endpoint__c` - The endpoint of the ws-dispatcher server instance. Default is _https://ws-dispatcher.onrender.com/ws_ but if you run ws-dispatcher on your own server, this property should be different (don't forget to add it to the Remote Site Settings).
-   `Timeout__c` - Timeout in milliseconds for the HTTP calls made to the ws-dispatcher. It defines how often the Listen job will send requests for fetching WebSocket updates. For example, if your WebSocket server usually sends messages rarely you should consider setting a high value (like 50000). If your WebSocket server sends messages often you should consider setting the lowest value (like 10000). The maximum value is 120000.
