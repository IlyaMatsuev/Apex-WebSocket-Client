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
                return reject(new ServiceError(`Whether no client id has been provided or it's incorrect`));
            }

            const timeoutTimer = setTimeout(() => {
                this.removeListeners(client!.id);
                reply(['Timeout. Reconnect again'], 'timeout');
            }, timeout);

            const reply = (data: string[], event: ResponseEvent): void => {
                clearTimeout(timeoutTimer);
                this.removeListeners(client!.id);
                resolve({ clientId: client!.id, messages: [...data], event });
            };

            if (client!.errors.hasUnread) {
                return reply(client!.errors.getUnread(), 'error');
            }

            if (client!.messages.hasUnread) {
                return reply(client!.messages.getUnread(), 'message');
            }

            if (!client!.connected) {
                store.removeClient(client!.id);
                return reply(['The connection is closed'], 'close');
            }

            store.once(`${client!.id}-message`, message => reply([message.getText()], 'message'));
            store.once(`${client!.id}-error`, error => reply([error.getText()], 'error'));
            store.once(`${client!.id}-close`, () => {
                store.removeClient(client!.id);
                reply(['The connection is closed'], 'close');
            });
        });
    }

    private removeListeners(clientId: string): void {
        Store.getStore().removeAllListeners(`${clientId}-message`);
        Store.getStore().removeAllListeners(`${clientId}-error`);
        Store.getStore().removeAllListeners(`${clientId}-close`);
    }
}
