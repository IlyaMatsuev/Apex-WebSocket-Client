import { connection, Message } from 'websocket';
import Store, { StoreEventType } from './store';

export default class WsClient {
    public readonly id: string;
    private connection: connection;
    private errors: string[] = [];
    private messages: string[] = [];
    private isClosed = false;

    public constructor(id: string, connection: connection) {
        this.id = id;
        this.connection = connection;
    }

    public addMessage(message: Message): void {
        this.failIfClosed();
        if (message.type === 'utf8') {
            this.messages.push(message.utf8Data);
            this.emit('message', [message.utf8Data]);
        }
    }

    public addError(error: string): void {
        this.failIfClosed();
        this.errors.push(error);
        this.emit('error', [error]);
    }

    public close(): void {
        this.failIfClosed();
        this.isClosed = true;
        Store.getStore().removeClient(this.id);
        this.emit('close');
    }

    private emit(eventType: StoreEventType, messages?: string[]): boolean {
        return Store.getStore().emit(this.id, eventType, messages);
    }

    private failIfClosed(): void {
        if (this.isClosed) {
            throw new Error('The client has already been closed: ' + this.id);
        }
    }
}
