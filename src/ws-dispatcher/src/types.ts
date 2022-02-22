export interface ICommand {
    execute(request: RequestPayload): Promise<ResponsePayload>;
}

export enum RequestCommand {
    Connect = 'connect',
    Listen = 'listen',
    Message = 'message',
    Close = 'close'
}

export enum ResponseEvent {
    Connect = 'connect',
    Timeout = 'timeout',
    Error = 'error',
    Message = 'message',
    Close = 'close'
}

export interface IConnectRequestPayload {
    command: RequestCommand.Connect;
    endpoint: string;
    protocol?: string;
}

export interface IMessageRequestPayload {
    command: RequestCommand.Message;
    clientId: string;
    message: string;
}

export interface IRequestPayload {
    command: RequestCommand.Listen | RequestCommand.Close;
    clientId: string;
}

export type RequestPayload = IConnectRequestPayload | IMessageRequestPayload | IRequestPayload;

export type ResponsePayload = {
    clientId: string;
    event: ResponseEvent;
    messages: string[];
};
