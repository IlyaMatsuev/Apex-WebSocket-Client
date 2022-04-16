import { Store } from '../store/store';
import { ICommand, ICloseRequestPayload, ResponseEvent, ResponsePayload } from '../types';

export default class CloseCommand implements ICommand {
    public async execute(request: ICloseRequestPayload): Promise<ResponsePayload> {
        const client = Store.getStore().getClient(request.clientId);
        if (client.connected) {
            client.close();
        }
        return { clientId: client.id, messages: ['Connection closed'], event: ResponseEvent.Close };
    }
}
