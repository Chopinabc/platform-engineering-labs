#########Stage 1: Build #############

FROM node:18-alpine AS build
WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && \
    npm cache clean --force


#########Stage 2: Prod #############

FROM node:18-alpine AS production
WORKDIR /app

RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser

COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup server.js package.json ./

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

EXPOSE 3000

CMD ["node", "server.js"]