#!/bin/bash
gem list | grep snappy && gem uninstall --force snappy
bundle exec rake clean build
gem install --force --local --no-ri --no-rdoc "$(ls pkg/snappy-*.gem)"
cat <<EOF | ruby
require 'snappy'
abort if Snappy.inflate(Snappy.deflate(File.read('smoke.sh'))) != File.read('smoke.sh')
EOF
