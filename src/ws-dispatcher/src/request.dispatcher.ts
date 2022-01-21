import ConnectCommand from './commands/connect';
import ListenCommand from './commands/listen';
import { fail } from './utils/respond';
import { FastifyReply } from 'fastify';
import { Request, ICommand, RequestCommand } from './types';

const commands: { [key in RequestCommand]: ICommand } = {
    connect: new ConnectCommand(),
    listen: new ListenCommand(),
    message: new ConnectCommand(),
    close: new ConnectCommand()
};

export default class RequestDispatcher {
    public static dispatch(request: Request, response: FastifyReply): void {
        if (request.command) {
            commands[request.command].execute(request, response);
        } else {
            fail(response, 'No command has been provided');
        }
    }
}
