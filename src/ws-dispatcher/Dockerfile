FROM --platform=linux/amd64 node:14.17.0-alpine
WORKDIR /app

COPY ./package.json ./
RUN apk add --update python3 make g++ && rm -rf /var/cache/apk/*
RUN npm install --silent

COPY . ./

EXPOSE 8000

CMD ["npm", "start"]
