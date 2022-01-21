import { connection, Message } from 'websocket';
import { Store, StoreEventType } from './store';

export default class WsClient {
    private errors: Error[] = [];
    private messages: Message[] = [];
    private isClosed = false;

    public constructor(public readonly id: string, private connection: connection) {}

    public addMessage(message: Message): void {
        this.failIfClosed();
        this.messages.push(message);
        this.emit('message', message);
    }

    public addError(error: Error): void {
        this.failIfClosed();
        this.errors.push(error);
        this.emit('error', error);
    }

    public close(): void {
        this.failIfClosed();
        this.isClosed = true;
        this.connection.close();
        Store.getStore().removeClient(this.id);
        this.emit('close');
    }

    private emit(eventType: StoreEventType, data?: Message | Error): boolean {
        return Store.getStore().emit(this.id, eventType, data);
    }

    private failIfClosed(): void {
        if (this.isClosed) {
            throw new Error('The client has already been closed: ' + this.id);
        }
    }
}
