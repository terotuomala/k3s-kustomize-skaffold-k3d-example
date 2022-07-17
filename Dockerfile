FROM node:18-slim as build

# Change working directory
WORKDIR /app

COPY src ./src

FROM node:18-slim as release

# Switch to non-root user uid=1000(node)
USER node

# Set node loglevel
ENV NPM_CONFIG_LOGLEVEL warn

# Change working directory
WORKDIR /home/node

# Copy app directory from build stage
COPY --chown=node:node --from=build /app .

EXPOSE 3000

CMD ["node", "src/index.js"]
