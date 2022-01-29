import { connection, Message } from 'websocket';
import { Store, StoreEventType } from './store';
import WsMessage from './ws.message';
import WsMessageCollection from './ws.message.collection';

export default class WsClient {
    public readonly errors: WsMessageCollection = new WsMessageCollection();
    public readonly messages: WsMessageCollection = new WsMessageCollection();

    public get connected() {
        return this.connection.connected;
    }

    public constructor(public readonly id: string, private connection: connection) {}

    public sendMessage(message: string): void {
        if (!this.connected) {
            throw new Error(`The client has been already closed: ${this.id}`);
        }
        this.connection.send(message);
    }

    public receiveMessage(message: Message | Error): void {
        if (!this.connected) {
            throw new Error(`The client has been already closed: ${this.id}`);
        }
        if ('type' in message) {
            this.emit('message', this.messages.push(message));
        } else {
            this.emit('error', this.errors.push(message));
        }
    }

    public close(force: boolean = false): void {
        if (force) {
            this.connection.removeAllListeners().close();
            Store.getStore().removeClient(this.id);
        }
        this.emit('close');
    }

    private emit(eventType: StoreEventType, data?: WsMessage): boolean {
        return Store.getStore().emit(this.id, eventType, data);
    }
}
