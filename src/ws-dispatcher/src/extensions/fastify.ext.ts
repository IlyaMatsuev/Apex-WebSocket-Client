import { FastifyPluginAsync, FastifyRequest } from 'fastify';
import fastifyPlugin from 'fastify-plugin';
import { Store } from '../store/store';
import { RequestPayload, RequestCommand } from './../types';
import { ValidationError } from './error.ext';

declare module 'fastify' {
    interface FastifyRequest {
        validateAndGetPayload(): RequestPayload;
    }
}

const MIN_LISTEN_TIMEOUT = 5000;
const MAX_LISTEN_TIMEOUT = 120000;

const validateAndGetPayload = function (this: FastifyRequest): RequestPayload {
    if (this.headers['content-type'] !== 'application/json') {
        throw new ValidationError(`Content-Type header must be passed as 'application/json'`);
    }

    const payload = {
        ...(this.body as RequestPayload),
        command: ((this.body as any).command as string)?.toLowerCase() as RequestCommand
    } as RequestPayload;

    if (!payload.command) {
        throw new ValidationError('No command has been provided');
    }

    if (!Object.values(RequestCommand).includes(payload.command)) {
        throw new ValidationError(`There is no such command: "${payload.command}"`);
    }

    if (payload.command === RequestCommand.Connect) {
        if (!payload.endpoint) {
            throw new ValidationError('The endpoint is required');
        }
        if (!payload.endpoint.startsWith('ws://') && !payload.endpoint.startsWith('wss://')) {
            throw new ValidationError('Invalid ws endpoint format');
        }
    } else if (!Store.getStore().hasClient(payload.clientId)) {
        throw new ValidationError(`Whether no client id has been provided or it's incorrect`);
    } else if (payload.command === RequestCommand.Listen) {
        if (!payload.timeout || payload.timeout < MIN_LISTEN_TIMEOUT || payload.timeout > MAX_LISTEN_TIMEOUT) {
            throw new ValidationError('Provide the valid timeout value');
        }
    }

    if (payload.command === RequestCommand.Message && !payload.message) {
        throw new ValidationError(`No message has been provided`);
    }

    return payload;
};

const plugin: FastifyPluginAsync = async fastify => {
    fastify.decorateRequest('validateAndGetPayload', validateAndGetPayload);
};

export default fastifyPlugin(plugin, '3.x');
