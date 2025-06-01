# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Enable Corepack (which manages Yarn versions)
RUN corepack enable# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Enable Corepack to manage Yarn versions (optional but recommended)
RUN corepack enable

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies, generating node_modules folder
RUN yarn install --frozen-lockfile

# Copy rest of the source code
COPY . .

# Build Next.js app
RUN yarn build

# Stage 2: Production image
FROM node:18-alpine AS runner

WORKDIR /app

# Enable Corepack
RUN corepack enable

# Copy necessary files from builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose port 3000
EXPOSE 3000

# Start app in production
CMD ["yarn", "start"]


# Copy package.json and yarn.lock to install dependencies
COPY package.json yarn.lock ./

# Install dependencies with the correct Yarn version (from Corepack)
RUN yarn install --frozen-lockfile

# Copy all source files
COPY . .

# Build the Next.js app
RUN yarn build

# Stage 2: Production image
FROM node:18-alpine AS runner

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose the port the app runs on
EXPOSE 3000

# Start the Next.js app in production mode
CMD ["yarn", "start"]
