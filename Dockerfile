# Build Stage
FROM node:18-slim AS builder

WORKDIR /src

# https://mediasoup.org/documentation/v3/mediasoup/installation/
ENV MEDIASOUP_SKIP_WORKER_PREBUILT_DOWNLOAD="true"

# Install build dependencies and Python 3
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json
COPY package.json .

# Install dependencies
RUN npm install --only=production

# Cleanup unnecessary dependencies and packages
RUN apt-get -y purge --auto-remove build-essential python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/.npm /root/.node-gyp

# Runtime Stage
FROM node:18-slim

WORKDIR /src

# Copy only necessary files from the build stage
COPY --from=builder /src .

# Copy app and public directories
COPY app app
COPY public public

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["/entrypoint.sh"]
