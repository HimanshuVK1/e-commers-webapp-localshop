# Stage 1: Build & Install
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm prune --production

# Stage 2: Runtime
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=build /app /app
ENV NODE_ENV production
USER 65532
EXPOSE 8001
CMD ["src/index.js"]
