# syntax = docker/dockerfile:labs
ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION}

ENV BUNDLE_JOBS=4

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt <<EOF
apt-get update
apt-get install -y \
  cmake
EOF

WORKDIR /app
