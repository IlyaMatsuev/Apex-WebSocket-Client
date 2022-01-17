import { FastifyReply } from 'fastify';
import { client as WebSocket } from 'websocket';
import { ICommand, Request } from '../types';
import { success, fail } from '../utils/respond';
import Store from '../store/store';

export default class ConnectCommand implements ICommand {
    public async execute(request: Request, response: FastifyReply): Promise<void> {
        const wsClient = new WebSocket();
        wsClient.connect(request.endpoint, request.protocol);
        wsClient
            .on('connectFailed', error => fail(response, 'Failed to connect: ' + error))
            .on('connect', connection => {
                const store = Store.getStore();
                const client = store.addClient(connection);

                connection
                    .on('error', error => client.addError(error.message))
                    .on('close', () => client.close())
                    .on('message', message => client.addMessage(message));

                success(response, { message: 'Connection established', event: 'connect' });
            });
    }
}
