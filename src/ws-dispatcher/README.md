# WS-Dispatcher

This is the Fastify server which redirects HTTP requests as WebSocket messages to the WebSocket server. When it recieves any updates from the server, it replies the HTTP response with the received messages.

## Deploy & Run

The server is running on Heroku at https://ws-dispatcher.herokuapp.com/ but I'd recommend you to deploy it as your own application, so it would work faster.

### With Heroku

You can deploy the server to your own heroku account. I prepared two scripts for this purpose: [`heroku-deploy.sh`](../../scripts/heroku-deploy.sh) and [`heroku-update.sh`](../../scripts/heroku-update.sh).

Go to the project `root directory` and run:

-   If you'd like to deploy server to a new heroku app

```
./scripts/heroku-deploy.sh <app_name>
```

-   If you'd like to deploy server to the existing heroku app

```
./scripts/heroku-update.sh <app_name>
```

### By Your Own

I prepared the [docker image](https://hub.docker.com/r/ilyamatsuev/ws-dispatcher), so you can deploy it anywhere you want (AWS, Azure, ...). Pull the docker image running:

```
docker pull ilyamatsuev/ws-dispatcher
```

#### NOTE

[comment]: # 'TODO: Add link to the WSDispatcherSetting documentation'

Don't forget to update the `WSDispatcherSetting` custom settings and `Remote Site Settings` if you use your own heroku app or any other platform.

## API

There is only one endpoint so far. However, there is `openapi.json` file which can be used to explore the WS Dispatcher API.
Import [`openapi.json`](openapi.json) file [here](https://editor.swagger.io)
