import { client as WebSocket } from 'websocket';
import { ICommand, IConnectRequestPayload, ResponseEvent, ResponsePayload } from '../types';
import { ServiceError } from '../extensions/error.ext';
import { Store } from '../store/store';

export default class ConnectCommand implements ICommand {
    public execute(request: IConnectRequestPayload): Promise<ResponsePayload> {
        return new Promise<ResponsePayload>((resolve, reject) => {
            const wsClient = new WebSocket();
            wsClient.on('connectFailed', error => reject(new ServiceError(`Failed to connect: ${error.message}`)));
            wsClient.on('connect', connection => {
                const client = Store.getStore().addClient(connection);

                connection.on('message', message => client.receiveMessage(message));
                connection.on('error', error => client.receiveMessage(error));
                connection.on('close', () => client.close());

                resolve({
                    clientId: client.id,
                    messages: ['Connection established'],
                    event: ResponseEvent.Connect
                });
            });
            wsClient.connect(request.endpoint, request.protocol);
        });
    }
}
