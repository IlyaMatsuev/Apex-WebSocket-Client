import { FastifyRequest } from 'fastify';
import { Request } from '../types';

export const validateRequest = (request: FastifyRequest): Request => {
    if (request.headers['content-type'] !== 'application/json') {
        throw new ValidationError(`Content-Type header must be passed as 'application/json'`);
    }

    const payload = request.body as Request;
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

export class ValidationError extends Error {}
