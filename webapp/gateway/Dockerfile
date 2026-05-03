# Stage 1: Build & Install
FROM node:20-alpine AS build
WORKDIR /app
# Copy package files for better caching
COPY package*.json ./
# Use clean install for reproducible builds
RUN npm ci
# Copy source code
COPY . .
# Prune development dependencies to keep production image small
RUN npm prune --production

# Stage 2: Runtime
# Using Google Distroless for security (no shell, no extra binaries)
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
# Copy only necessary files from build stage
COPY --from=build /app /app
# Set environment to production
ENV NODE_ENV production
# Set user to non-root for security (UID 65532 is default for nonroot)
USER 65532
EXPOSE 8000
# Run the application directly with node
CMD ["src/index.js"]
