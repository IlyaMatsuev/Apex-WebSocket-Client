import { ICommand, IListenRequestPayload, ResponseEvent, ResponsePayload } from '../types';
import { Store } from '../store/store';
import { logger } from '..';
import { defaultListenTimeout } from './../config.json';

const defaultTimeout = Number(process.env.DEFAULT_LISTEN_TIMEOUT) || defaultListenTimeout;

export default class ListenCommand implements ICommand {
    public execute(request: IListenRequestPayload): Promise<ResponsePayload> {
        return new Promise<ResponsePayload>(resolve => {
            const store = Store.getStore();
            const client = store.getClient(request.clientId);

            const timeoutTimer = setTimeout(() => {
                this.removeListeners(client.id);
                reply(['Timeout. Reconnect again'], ResponseEvent.Timeout);
            }, this.getTimeout(request.timeout));

            const reply = (data: string[], event: ResponseEvent): void => {
                logger.info(`Reply with event: ${event}`);
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
                return reply(['The connection is closed'], ResponseEvent.Close);
            }

            store.once(`${client.id}-message`, message => reply([message.getText()], ResponseEvent.Message));
            store.once(`${client.id}-error`, error => reply([error.getText()], ResponseEvent.Error));
            store.once(`${client.id}-close`, () => reply(['The connection is closed'], ResponseEvent.Close));
        });
    }

    private getTimeout(proposedTimeout: number): number {
        if (proposedTimeout) {
            // Set one second less to avoid timeout exception on the Apex side
            return proposedTimeout - 1000;
        }
        return defaultTimeout;
    }

    private removeListeners(clientId: string): void {
        Store.getStore().removeAllListeners(`${clientId}-message`);
        Store.getStore().removeAllListeners(`${clientId}-error`);
        Store.getStore().removeAllListeners(`${clientId}-close`);
    }
}
