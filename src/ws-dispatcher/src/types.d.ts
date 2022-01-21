import { FastifyReply } from 'fastify';

export interface ICommand {
    execute(request: Request, response: FastifyReply): Promise<void>;
}

export type RequestCommand = 'connect' | 'listen' | 'message' | 'close';

export type ResponseEvent = 'connect' | 'timeout' | 'error' | 'message' | 'close';

export type Request = {
    command: RequestCommand;
    endpoint: string;
    clientId?: string;
    protocol?: string;
};

export type Response = {
    clientId?: string;
    event: ResponseEvent;
    message: string;
};
