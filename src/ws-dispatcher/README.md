# WS-Dispatcher

This is the Fastify server which redirects HTTP requests as WebSocket messages to the WebSocket server. When it receives any updates from the server, it replies to the HTTP response with the received messages.

## Deploy & Run

The server is running on Render at https://ws-dispatcher.onrender.com/ but I'd recommend you to deploy it as your own application, so it would work faster.

### With Render

To create your own instance of ws-dispatcher on Render you'd need to fork this repository. Then, when you sign up at render.com and create a new WebService app, you can connect your new fork repository. It will automatically detect docker image but you'll need to provide path to `the Docker build context` and `Dockerfile`:

-   Docker build context: src/ws-dispatcher
-   Dockerfile: src/ws-dispatcher/Dockerfile

The just create the app and wait till it started, you'll get your own domain that you can use.

### With Heroku (not free anymore)

You can deploy the server to your own Heroku account. I prepared two scripts for this purpose: [`heroku-deploy.sh`](../../scripts/heroku-deploy.sh) and [`heroku-update.sh`](../../scripts/heroku-update.sh).

Go to the project `root directory` and run:

-   If you'd like to deploy server to a new Heroku app

```
./scripts/heroku-deploy.sh <app_name>
```

-   If you'd like to deploy server to the existing Heroku app

```
./scripts/heroku-update.sh <app_name>
```

### By Your Own

I prepared the [docker image](https://hub.docker.com/r/ilyamatsuev/ws-dispatcher), so you can deploy it anywhere you want (AWS, Azure, etc.). Pull the docker image running:

```
docker pull ilyamatsuev/ws-dispatcher
```

#### NOTE

Don't forget to update the [`WSDispatcherSetting`](../../docs/README.md#wsdispatchersettingc) custom settings and Remote Site Settings if you use your own Render app or any other platform.

## API

There is only one endpoint so far. However, there is the `openapi.json` file that can be used to explore the WS Dispatcher API.
Import [`openapi.json`](openapi.json) file [here](https://editor.swagger.io)
