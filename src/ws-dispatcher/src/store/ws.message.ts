import { Message } from 'websocket';

export default class WsMessage {
    private read: boolean = false;
    private text: string;

    public get isRead() {
        return this.read;
    }

    public constructor(message: Message | Error) {
        if ('type' in message) {
            this.text = message.type === 'utf8' ? message.utf8Data : message.binaryData.toString();
        } else {
            this.text = message.message;
        }
    }

    public getText(): string {
        this.markRead();
        return this.text;
    }

    public markRead(): void {
        this.read = true;
    }
}
