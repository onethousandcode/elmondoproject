# Use official Node.js LTS image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first (for caching)
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the source code
COPY . .

# Build the NestJS app
RUN npm run build

# Expose NestJS port
EXPOSE 4000

# Start in production mode
CMD ["npm", "run", "start:prod"]
