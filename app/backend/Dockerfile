# syntax=docker/dockerfile:1

# ---- Build stage ----
# Compile TypeScript and generate the Prisma client
FROM node:lts-alpine AS builder

WORKDIR /app

RUN apk add --no-cache openssl

COPY package.json package-lock.json ./
RUN npm ci

COPY prisma ./prisma/
RUN npx prisma generate

COPY tsconfig.json ./
COPY src ./src/
RUN npm run build

# ---- Production stage ----
# Minimal runtime image
FROM node:lts-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

RUN apk add --no-cache openssl

RUN addgroup --system --gid 1001 nodejs \
  && adduser --system --uid 1001 --ingroup nodejs appuser

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY prisma ./prisma/
RUN npm install prisma@^6.19.0 --no-save && npm cache clean --force

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

# Generated Prisma client (query engine) from the build stage
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/dist ./dist

USER appuser

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
