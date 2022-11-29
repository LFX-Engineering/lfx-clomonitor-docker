# Copyright The Linux Foundation and each contributor to LFX.
# SPDX-License-Identifier: MIT

#------------------------------------------------------------------------------
# Download the OSSF scorecard binary
#------------------------------------------------------------------------------
FROM ubuntu:22.04 AS build_scorecard
ARG SCORECARD_VERSION=4.8.0
ARG BUILD_HOST=linux
ARG BUILD_ARCH=amd64
ARG ARCHIVE_FILE=scorecard_${SCORECARD_VERSION}_${BUILD_HOST}_${BUILD_ARCH}.tar.gz
ARG DOWNLOAD_FILE=https://github.com/ossf/scorecard/releases/download/v${SCORECARD_VERSION}/${ARCHIVE_FILE}
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN echo "Downloading ${DOWNLOAD_FILE} to ${ARCHIVE_FILE}..." && \
    curl -o ${ARCHIVE_FILE} -L ${DOWNLOAD_FILE} && \
    tar -xvzf ${ARCHIVE_FILE} && \
    rm -f LICENSE README.md && \
    mv scorecard-${BUILD_HOST}-${BUILD_ARCH} scorecard

#------------------------------------------------------------------------------
# Download and build the CLO Monitor using rust cargo
#------------------------------------------------------------------------------
FROM rust:1-slim-bullseye AS build_clomonitor_linter
RUN apt-get update && apt-get install -y curl build-essential ca-certificates file xutils-dev nmap && rm -rf /var/lib/apt/lists/*
RUN cargo install --git https://github.com/cncf/clomonitor clomonitor-linter && cp /usr/local/cargo/bin/clomonitor-linter clomonitor-linter

#------------------------------------------------------------------------------
# Our final image
#------------------------------------------------------------------------------
FROM ubuntu:22.04
WORKDIR /app

# Install additional tools
RUN apt-get update && apt-get install -y curl git jq && apt upgrade -y && rm -rf /var/lib/apt/lists/*

# Copy over the tools into the docker image
COPY --from=build_scorecard scorecard scorecard
COPY --from=build_clomonitor_linter clomonitor-linter clomonitor-linter

# Update PATH
ENV PATH="$PATH:./:/app"

CMD [ "/app/clomonitor-linter" ]
