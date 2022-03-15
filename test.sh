#!/bin/bash
docker build -t miyucy/snappy .
docker run --rm -v "$(pwd):/app" miyucy/snappy bash -c 'bundle install && bundle exec rake'
