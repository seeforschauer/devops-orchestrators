FROM node:24-alpine

WORKDIR /app

RUN apk add --no-cache \
    bash \
    curl \
    git \
    && rm -rf /var/cache/apk/*

RUN mkdir -p logs
COPY package*.json ./
COPY tsconfig.json ./

RUN npm install

COPY src/ ./src/
COPY .env_example ./.env_example

COPY setup.sh start.sh ./
RUN chmod +x setup.sh start.sh

RUN npm run build

RUN if [ ! -f .env ]; then cp .env_example .env; fi

# running the app having the lock file in the container... -> \
# lock file becomes unnecessary now, bcz docker takes care of it.

EXPOSE 4000

ENV NODE_ENV=production

VOLUME ["/app/logs", "/app/.env"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:4000/healthz || exit 1

CMD ["sh", "-c", "TIMESTAMP=$(date +\"%Y%m%d_%H%M%S\") && mkdir -p logs && exec npm start 2>&1 | tee logs/output_$TIMESTAMP.log"]
