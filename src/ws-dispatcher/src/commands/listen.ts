import { ICommand, IRequestPayload, ResponseEvent, ResponsePayload } from '../types';
import { Store } from '../store/store';
import { timeout } from './../config.json';

export default class ListenCommand implements ICommand {
    public execute(request: IRequestPayload): Promise<ResponsePayload> {
        return new Promise<ResponsePayload>(resolve => {
            const store = Store.getStore();
            const client = store.getClient(request.clientId);

            const timeoutTimer = setTimeout(() => {
                this.removeListeners(client.id);
                reply(['Timeout. Reconnect again'], ResponseEvent.Timeout);
            }, timeout);

            const reply = (data: string[], event: ResponseEvent): void => {
                clearTimeout(timeoutTimer);
                this.removeListeners(client.id);
                resolve({ clientId: client.id, messages: [...data], event });
            };

            if (client.errors.hasUnread) {
                return reply(client.errors.getUnread(), ResponseEvent.Error);
            }

            if (client.messages.hasUnread) {
                return reply(client.messages.getUnread(), ResponseEvent.Message);
            }

            if (!client.connected) {
                store.removeClient(client.id);
                return reply(['The connection is closed'], ResponseEvent.Close);
            }

            store.once(`${client.id}-message`, message => reply([message.getText()], ResponseEvent.Message));
            store.once(`${client.id}-error`, error => reply([error.getText()], ResponseEvent.Error));
            store.once(`${client.id}-close`, () => {
                store.removeClient(client.id);
                reply(['The connection is closed'], ResponseEvent.Close);
            });
        });
    }

    private removeListeners(clientId: string): void {
        Store.getStore().removeAllListeners(`${clientId}-message`);
        Store.getStore().removeAllListeners(`${clientId}-error`);
        Store.getStore().removeAllListeners(`${clientId}-close`);
    }
}
