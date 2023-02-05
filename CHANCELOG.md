# Unreleased

Package name:
Package Id:

## What's changed

### Move from Heroku

The ws-dispatcher server has been moved from Heroku to [Render](https://render.com) since Heroku doesn't provide free services anymore.

### Add ApexDoc

All `global` classes and their members now have ApexDoc comments to help developers work in their IDEAs with the package.

### Prevent connection usage when it's already closed

If the `WSConnection` connection was already closed it will not be possible anymore to send a new message or listen to the updates, which will prevent not needed load on the ws-dispatcher.

Please, open a discussion or issue if you face any problems with the package. Best regards!

# Version 1.0

Package name: ws-apex-client@1.0.0-0
Package Id: 04t5Y000001wMt5QAE

All information regarding the installation and usage is described on the [main repo page](https://github.com/IlyaMatsuev/Apex-WebSocket-Client).
