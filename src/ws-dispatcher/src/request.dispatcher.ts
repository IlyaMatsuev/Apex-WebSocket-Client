import ConnectCommand from './commands/connect';
import ListenCommand from './commands/listen';
import CloseCommand from './commands/close';
import MessageCommand from './commands/message';
import { RequestPayload, ICommand, RequestCommand, ResponsePayload } from './types';
import { logger } from '.';

const commands: { [key in RequestCommand]: ICommand } = {
    connect: new ConnectCommand(),
    listen: new ListenCommand(),
    message: new MessageCommand(),
    close: new CloseCommand()
};

export default class RequestDispatcher {
    private constructor() {}

    public static dispatch(request: RequestPayload): Promise<ResponsePayload> {
        logger.info(`Executing command: ${request.command}`);
        return commands[request.command].execute(request);
    }
}
