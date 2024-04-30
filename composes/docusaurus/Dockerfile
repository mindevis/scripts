FROM node:current-alpine

RUN npx create-docusaurus@latest /app classic --javascript

WORKDIR /app

RUN cd /app && yarn install

CMD ["yarn", "start", "--host", "0.0.0.0"]