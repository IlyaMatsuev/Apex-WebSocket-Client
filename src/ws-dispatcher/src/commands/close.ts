import { Store } from '../store/store';
import { ICommand, IRequestPayload, ResponsePayload } from '../types';

export default class CloseCommand implements ICommand {
    public async execute(request: IRequestPayload): Promise<ResponsePayload> {
        const client = Store.getStore().getClient(request.clientId);
        if (client.connected) {
            client.close(true);
        }
        return { clientId: client.id, messages: ['The connection is closed'], event: 'close' };
    }
}