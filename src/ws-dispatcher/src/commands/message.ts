import { Store } from '../store/store';
import { ICommand, IMessageRequestPayload, ResponseEvent, ResponsePayload } from '../types';

export default class MessageCommand implements ICommand {
    public async execute(request: IMessageRequestPayload): Promise<ResponsePayload> {
        const client = Store.getStore().getClient(request.clientId);
        if (client.connected) {
            client.sendMessage(request.message);
        }
        return { clientId: client.id, messages: ['The message has been sent'], event: ResponseEvent.Message };
    }
}
