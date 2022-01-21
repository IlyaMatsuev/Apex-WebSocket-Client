import http from 'http';
import { server as WebSocket } from 'websocket';
const { 'test-ws-server': config } = require('./../../../config.json');

const port = config.port as number;
const messageInterval = config.messageInterval as number;

const httpServer = http.createServer((_, response) => response.writeHead(404).end());

httpServer.listen(port, () => {
    console.info(`Http server is listening on port ${port}`);
});

new WebSocket({ httpServer }).on('request', request => {
    if (!isAllowedOrigin(request.origin)) {
        request.reject();
        return;
    }

    const connection = request.accept('echo-protocol', request.origin);

    console.info('Connection has been opened');

    connection
        .on('message', message => {
            if (message.type === 'utf8') {
                console.info(`Received message: ${message.utf8Data}`);
                connection.send(message.utf8Data);
            } else {
                console.info(`Received binary message of ${message.binaryData.length} bytes`);
                connection.send(message.binaryData);
            }
        })
        .on('close', () => console.info('Connection has been closed'));

    let sentMessageCount = 0;
    setInterval(() => connection.send(`Ping ${sentMessageCount++}`), messageInterval);
});

function isAllowedOrigin(origin: string) {
    console.log(`Origin: ${origin}`);
    return true;
}
