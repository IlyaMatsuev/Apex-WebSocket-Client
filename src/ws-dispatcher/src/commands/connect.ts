import { client as WebSocket } from 'websocket';
import { ICommand, RequestPayload, ResponsePayload, ServiceError } from '../types';
import { Store } from '../store/store';

export default class ConnectCommand implements ICommand {
    public async execute(request: RequestPayload): Promise<ResponsePayload> {
        return new Promise<ResponsePayload>((resolve, reject) => {
            const wsClient = new WebSocket();
            wsClient.connect(request.endpoint, request.protocol);
            wsClient
                .on('connectFailed', error => reject(new ServiceError(`Failed to connect: ${error.message}`)))
                .on('connect', connection => {
                    const client = Store.getStore().addClient(connection);

                    connection
                        .on('error', error => client.addError(error))
                        .on('close', () => client.close())
                        .on('message', message => client.addMessage(message));

                    resolve({ clientId: client.id, message: 'Connection established', event: 'connect' });
                });
        });
    }
}
