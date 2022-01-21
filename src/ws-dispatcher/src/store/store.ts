import { EventEmitter } from 'stream';
import { v4 as uuid } from 'uuid';
import { connection, Message } from 'websocket';
import WsClient from './ws.client';

export type StoreEventType = 'message' | 'error' | 'close';

export declare interface Store {
    once(event: `${string}-message`, cb: (data: Message) => void): this;
    once(event: `${string}-error`, cb: (err: Error) => void): this;
    once(event: `${string}-close`, cb: (code: number, desc: string) => void): this;
}

export class Store extends EventEmitter {
    private static store: Store;
    private clients = new Map<string, WsClient>();

    private constructor() {
        super();
    }

    public static getStore(): Store {
        if (!this.store) {
            this.store = new Store();
        }
        return this.store;
    }

    public getClientOrNull(id: string | undefined): WsClient | null | undefined {
        return id ? this.clients.get(id) : null;
    }

    public addClient(connection: connection): WsClient {
        const client = new WsClient(uuid(), connection);
        this.clients.set(client.id, client);
        return client;
    }

    public removeClient(clientId: string): void {
        // TODO: check whether it's possible to delete all listeners for a particular string event name
        // Or maybe I don't need this since I'm firing 'closed' event, so the listeners can close themselves
        this.clients.delete(clientId);
    }

    public override emit(clientId: string, eventType: StoreEventType, data?: Message | Error): boolean {
        return super.emit(`${clientId}-${eventType}`, data);
    }
}
