import { FastifyPluginAsync, FastifyRequest } from 'fastify';
import fastifyPlugin from 'fastify-plugin';
import { RequestPayload } from './../types';
import { ValidationError } from './error.ext';

declare module 'fastify' {
    interface FastifyRequest {
        validateAndGetPayload(): RequestPayload;
    }
}

const validateAndGetPayload = function (this: FastifyRequest): RequestPayload {
    if (this.headers['content-type'] !== 'application/json') {
        throw new ValidationError(`Content-Type header must be passed as 'application/json'`);
    }

    const payload = this.body as RequestPayload;
    if (!payload.command) {
        throw new ValidationError('The command is required');
    }
    if (!payload.endpoint) {
        throw new ValidationError('The endpoint is required');
    }
    if (!payload.endpoint.startsWith('ws://') && !payload.endpoint.startsWith('wss://')) {
        throw new ValidationError('Invalid ws endpoint format');
    }
    return payload;
};

const plugin: FastifyPluginAsync = async fastify => {
    fastify.decorateRequest('validate', validateAndGetPayload);
};

export default fastifyPlugin(plugin, '3.x');
