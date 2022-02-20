import RequestDispatcher from './request.dispatcher';
import Fastify from 'fastify';
import middie from 'middie';
import cors from 'cors';
import fastifyExtention from './extensions/fastify.ext';
import { ValidationError, ServiceError } from './extensions/error.ext';
import config from './config.json';

const port = process.env.PORT || config.port;
const apiPath = config.apiPath;

const server = Fastify({ logger: config.logger });

server.register(middie);
server.register(() => server.use(cors({ methods: 'POST' })));
server.register(fastifyExtention);

server.get('/', (_, response) => {
    response.send(`Make a POST request towards ${apiPath} to start working with WebSockets`);
});

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

server.listen(port, '0.0.0.0', (err, address) => {
    if (err) {
        server.log.error(err);
        process.exit(1);
    }
    server.log.info(`The server is running at ${address}${apiPath}`);
});

export const logger = server.log;
