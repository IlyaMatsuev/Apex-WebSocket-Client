import { FastifyReply } from 'fastify';

export interface ICommand {
    execute(request: Request, response: FastifyReply): Promise<void>;
}

export type RequestCommand = 'connect' | 'reconnect' | 'message' | 'close';

export type ResponseEvent = 'connect' | 'timeout' | 'error' | 'message' | 'close';

export type Request = {
    command: RequestCommand;
    endpoint: string;
    protocol?: string;
};

export type Response = {
    event: ResponseEvent;
    message: string;
};
