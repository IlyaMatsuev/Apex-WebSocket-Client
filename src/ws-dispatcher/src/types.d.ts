import { FastifyReply } from 'fastify';

export interface ICommand {
    execute(request: RequestPayload): Promise<ResponsePayload>;
}

export type RequestCommand = 'connect' | 'listen' | 'message' | 'close';

export type ResponseEvent = 'connect' | 'timeout' | 'error' | 'message' | 'close';

export type RequestPayload = {
    command: RequestCommand;
    endpoint: string;
    clientId?: string;
    protocol?: string;
};

export type ResponsePayload = {
    clientId?: string;
    event: ResponseEvent;
    message: string;
};
