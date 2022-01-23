import { ICommand, RequestPayload, ResponseEvent, ResponsePayload } from '../types';
import { ServiceError } from '../extensions/error.ext';
import { Store } from '../store/store';
import { timeout } from './../config.json';

export default class ListenCommand implements ICommand {
    public async execute(request: RequestPayload): Promise<ResponsePayload> {
        return new Promise<ResponsePayload>((resolve, reject) => {
            const store = Store.getStore();
            const client = store.getClientOrNull(request.clientId);
            if (!client) {
                reject(new ServiceError('Whether no client id has been provided or there is no such client'));
                return;
            }

            const timeoutTimer = setTimeout(() => {
                this.removeListeners(client.id);
                reply('Timeout. Reconnect again', 'timeout');
            }, timeout);

            const reply = (message: string, event: ResponseEvent): void => {
                clearTimeout(timeoutTimer);
                this.removeListeners(client.id);
                resolve({ clientId: client.id, message, event });
            };

            store
                .once(`${client.id}-message`, message =>
                    reply(message.type === 'utf8' ? message.utf8Data : message.binaryData.toString(), 'message')
                )
                .once(`${client.id}-error`, error => reply(error.message, 'error'))
                .once(`${client.id}-close`, () => reply('The connection is closed', 'close'));
        });
    }

    private removeListeners(clientId: string): void {
        Store.getStore().removeAllListeners(`${clientId}-message`);
        Store.getStore().removeAllListeners(`${clientId}-error`);
        Store.getStore().removeAllListeners(`${clientId}-close`);
    }
}
