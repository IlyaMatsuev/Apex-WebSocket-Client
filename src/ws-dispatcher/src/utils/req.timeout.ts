import { FastifyReply } from 'fastify';
import { success } from './respond';
import config from './../config.json';

export const setRequestTimeout = (response: FastifyReply): NodeJS.Timeout => {
    return setTimeout(() => {
        success(response, { message: 'Connect again to continue', event: 'timeout' });
    }, config.server.timeout);
};
