import RequestDispatcher from './request.dispatcher';
import Fastify from 'fastify';
import { fail } from './utils/respond';
import { validateRequest, ValidationError } from './utils/validate';
const { 'ws-dispatcher': config } = require('./../../../config.json');

const port = (process.env.PORT || config.port) as number;
const apiPath = config.apiPath as string;

const server = Fastify({ logger: true });

// TODO: validate income request with fastify schema
// TODO: throw 404 if the url is different

server.get(apiPath, async (_, response) => {
    response.send({ message: 'hello' });
});

server.post(apiPath, (request, response) => {
    try {
        RequestDispatcher.dispatch(validateRequest(request), response);
    } catch (error) {
        if (error instanceof ValidationError) {
            fail(response, error.message);
        } else {
            server.log.error(`Error: ${error}`);
            fail(response, 'Something is went wrong on the server side');
        }
    }
});

server.listen(port, (err, address) => {
    if (err) {
        server.log.error(err);
        process.exit(1);
    }
    server.log.info(`The server is running on port ${port} by address ${address}${apiPath}`);
});
