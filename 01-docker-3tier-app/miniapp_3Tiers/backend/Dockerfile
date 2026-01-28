########## Stage 1: Dependencies ##########
FROM node:18-alpine AS dependencies
WORKDIR /app

# Copier package.json
COPY package*.json ./

# Install les prod dependencies
RUN npm ci --only=production && \
    npm cache clean --force




########## Stage 2: Production
FROM node:18-alpine AS production
WORKDIR /app

# Créer un user non-root
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser

# Copier node_modules depuis stage 1
COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules

# Copier le code applicatif
COPY --chown=appuser:appgroup server.js package.json ./

# Changer vers user non-root
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

EXPOSE 3000

CMD ["node", "server.js"]