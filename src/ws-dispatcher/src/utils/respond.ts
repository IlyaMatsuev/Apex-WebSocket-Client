import { FastifyReply } from 'fastify';
import { Response } from '../types';

export const success = (response: FastifyReply, body: Response): void => {
    if (response && !response.sent) {
        response.send(body);
    }
};

export const fail = (response: FastifyReply, message: string): void => {
    if (response && !response.raw.writableEnded) {
        response.status(400).send({ message, event: 'error' });
    }
};
