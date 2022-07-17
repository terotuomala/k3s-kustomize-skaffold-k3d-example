FROM node:18-slim as build

# Change working directory
WORKDIR /app

COPY src ./src

RUN npm i -g nodemon


FROM node:18-slim as release

# Switch to non-root user uid=1000(node)
USER node

# Set node loglevel
ENV NPM_CONFIG_LOGLEVEL warn

# Change working directory
WORKDIR /home/node

# Copy app directory from build stage
COPY --chown=node:node --from=build /app .
COPY --chown=node:node --from=build /usr/local/lib/node_modules/nodemon .npm-global/bin/nodemon

EXPOSE 3000

CMD ["node", "src/index.js"]
