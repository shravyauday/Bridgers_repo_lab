# Use official Node.js Alpine image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy dependency manifests first (better caching)
COPY package*.json ./

# Copy application source
COPY . .

# Make scripts executable
RUN chmod +x setup.sh start.sh

# Expose application port
EXPOSE 3000

# Start app at runtime
CMD ["./install.sh"]
