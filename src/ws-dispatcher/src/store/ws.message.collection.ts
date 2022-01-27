import { Message } from 'websocket';
import WsMessage from './ws.message';

export default class WsMessageCollection {
    private messages: WsMessage[] = [];

    public get hasUnread() {
        return !!this.messages.find(m => !m.isRead);
    }

    public push(message: Message | Error): WsMessage {
        const newMessage = new WsMessage(message);
        this.messages.push(newMessage);
        return newMessage;
    }

    public getUnread(): string[] {
        return this.messages.filter(m => !m.isRead).map(m => m.getText());
    }
}
