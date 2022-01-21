import { FastifyReply } from 'fastify';
import { ICommand, Request, ResponseEvent } from '../types';
import { Store } from '../store/store';
import { success } from '../utils/respond';
const { 'ws-dispatcher': config } = require('./../../../../config.json');

export default class ListenCommand implements ICommand {
    public async execute(request: Request, response: FastifyReply): Promise<void> {
        const store = Store.getStore();
        const client = store.getClientOrNull(request.clientId);
        if (!client) {
            throw new Error('Whether no client id has been provided or there is no such client');
        }

        const timeoutTimer = setTimeout(() => {
            this.removeListeners(client.id);
            reply('Timeout. Reconnect again', 'timeout');
        }, config.timeout);

        const reply = (message: string, event: ResponseEvent): void => {
            clearTimeout(timeoutTimer);
            this.removeListeners(client.id);
            success(response, { clientId: client.id, message, event });
        };

        store
            .once(`${client.id}-message`, message =>
                reply(message.type === 'utf8' ? message.utf8Data : message.binaryData.toString(), 'message')
            )
            .once(`${client.id}-error`, error => reply(error.message, 'error'))
            .once(`${client.id}-close`, () => reply('The connection is closed', 'close'));
    }

    private removeListeners(clientId: string): void {
        Store.getStore().removeAllListeners(`${clientId}-message`);
        Store.getStore().removeAllListeners(`${clientId}-error`);
        Store.getStore().removeAllListeners(`${clientId}-close`);
    }
}
