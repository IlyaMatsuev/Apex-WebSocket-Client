import RequestDispatcher from './request.dispatcher';
import Fastify from 'fastify';
import fastifyExtention from './extensions/fastify.ext';
import { ValidationError, ServiceError } from './extensions/error.ext';
import config from './config.json';

const port = process.env.PORT || config.port;
const apiPath = config.apiPath;

const server = Fastify({ logger: config.logger });

// TODO: validate income request with fastify schema
// TODO: throw 404 if the url is different

server.register(fastifyExtention);

server.post(apiPath, async (request, response) => {
    try {
        response.send(await RequestDispatcher.dispatch(request.validateAndGetPayload()));
    } catch (error) {
        if (error instanceof ValidationError || error instanceof ServiceError) {
            response.status(400).send({ message: error.message, event: 'error' });
        } else {
            server.log.error(`Error: ${error}`);
            response.status(500).send({ message: 'Something is went wrong on the server side', event: 'error' });
        }
    }
});

server.listen(port, (err, address) => {
    if (err) {
        server.log.error(err);
        process.exit(1);
    }
    server.log.info(`The server is running at ${address}${apiPath}`);
});

export const logger = server.log;
