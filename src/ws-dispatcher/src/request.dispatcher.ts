import ConnectCommand from './commands/connect';
import ListenCommand from './commands/listen';
import { RequestPayload, ICommand, RequestCommand, ServiceError, ResponsePayload } from './types';

const commands: { [key in RequestCommand]: ICommand } = {
    connect: new ConnectCommand(),
    listen: new ListenCommand(),
    message: new ConnectCommand(),
    close: new ConnectCommand()
};

export default class RequestDispatcher {
    private constructor() {}

    public static dispatch(request: RequestPayload): Promise<ResponsePayload> {
        if (!request.command) {
            throw new ServiceError('No command has been provided');
        }
        return commands[request.command].execute(request);
    }
}
