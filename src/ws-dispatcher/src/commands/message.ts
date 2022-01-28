import { Store } from '../store/store';
import { ICommand, IMessageRequestPayload, ResponsePayload } from '../types';
import ListenCommand from './listen';

export default class MessageCommand implements ICommand {
    public execute(request: IMessageRequestPayload): Promise<ResponsePayload> {
        const client = Store.getStore().getClient(request.clientId);
        if (client.connected) {
            client.sendMessage(request.message);
        }
        return new ListenCommand().execute({ ...request, command: 'listen' });
    }
}
