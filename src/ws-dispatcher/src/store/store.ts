import { EventEmitter } from 'stream';
import { v4 as uuid } from 'uuid';
import { connection } from 'websocket';
import WsClient from './ws.client';
import WsMessage from './ws.message';

export type StoreEventType = 'message' | 'error' | 'close';

export declare interface Store {
    once(event: `${string}-message`, cb: (data: WsMessage) => void): this;
    once(event: `${string}-error`, cb: (err: WsMessage) => void): this;
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

    public hasClient(id: string | undefined): boolean {
        return !!id && this.clients.has(id);
    }

    public getClient(id: string): WsClient {
        return this.clients.get(id)!;
    }

    public addClient(connection: connection): WsClient {
        const client = new WsClient(uuid(), connection);
        this.clients.set(client.id, client);
        return client;
    }

    public removeClient(clientId: string): void {
        this.clients.delete(clientId);
    }

    public override emit(clientId: string, eventType: StoreEventType, data?: WsMessage): boolean {
        return super.emit(`${clientId}-${eventType}`, data);
    }
}
