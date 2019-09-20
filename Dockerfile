FROM node:12-alpine as build

# Change working directory
WORKDIR /app

COPY package.json ./

COPY src ./src

RUN yarn

FROM node:12-alpine as release

# Switch to user node
USER node

# Set node loglevel
ENV NPM_CONFIG_LOGLEVEL warn

# Change working directory
WORKDIR /home/node

# Copy app directory from build stage
COPY --chown=node:node --from=build /app .

EXPOSE 3000
