# Stage 1: dependencies install
FROM node:18-alpine AS deps

WORKDIR /app

# Enable Corepack to manage Yarn version
RUN corepack enable

# Copy package files and .yarnrc.yml (to configure node_modules linker)
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies with node_modules linker
RUN yarn install --frozen-lockfile

# Stage 2: build
FROM node:18-alpine AS build

WORKDIR /app

RUN corepack enable

# Copy all files
COPY . .

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Build Next.js app
RUN yarn build

# Stage 3: runner (production image)
FROM node:18-alpine AS production

WORKDIR /app

RUN corepack enable

# Copy necessary files from build stage
COPY --from=build /app/package.json ./
COPY --from=build /app/yarn.lock ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

EXPOSE 3000

CMD ["yarn", "start"]
