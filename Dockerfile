FROM node:18-slim 

WORKDIR /src

# https://mediasoup.org/documentation/v3/mediasoup/installation/
ENV MEDIASOUP_SKIP_WORKER_PREBUILT_DOWNLOAD="true"

# Install build dependencies and Python 3
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json
COPY package.json .
COPY package-lock.json .

# Install dependencies
RUN npm ci --only=production && \
    apt-get -y purge --auto-remove build-essential python3-pip

# Copy app and public directories
COPY app app
COPY public public

CMD npm start