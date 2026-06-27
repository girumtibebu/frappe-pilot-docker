FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache git python3 make g++

RUN git clone https://github.com/frappe/pilot.git .

RUN find . -name package.json

RUN npm install

RUN npm run build

EXPOSE 8000

CMD ["npm","start"]
