import { FastifyReply } from 'fastify';

export interface ICommand {
    execute(request: RequestPayload): Promise<ResponsePayload>;
}

export type RequestCommand = 'connect' | 'listen' | 'message' | 'close';

export type ResponseEvent = 'connect' | 'timeout' | 'error' | 'message' | 'close';

export interface IConnectRequestPayload {
    command: 'connect';
    endpoint: string;
    protocol?: string;
}

export interface IMessageRequestPayload {
    command: 'message';
    clientId: string;
    message: string;
}

export interface IRequestPayload {
    command: 'listen' | 'close';
    clientId: string;
}

export type RequestPayload = IConnectRequestPayload | IMessageRequestPayload | IRequestPayload;

export type ResponsePayload = {
    clientId: string;
    event: ResponseEvent;
    messages: string[];
};
