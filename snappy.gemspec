# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snappy/version'

Gem::Specification.new do |spec|
  spec.name          = "snappy"
  spec.version       = Snappy::VERSION
  spec.authors       = ["miyucy"]
  spec.email         = ["fistfvck@gmail.com"]
  spec.description   = %q{libsnappy binding for Ruby}
  spec.summary       = %q{libsnappy binding for Ruby}
  spec.homepage      = "http://github.com/miyucy/snappy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  if defined?(JRUBY_VERSION)
    spec.files += %w[lib/snappy_ext.jar]
    spec.platform = 'java'
    spec.add_dependency 'snappy-jars', '~> 1.1.0'
  else
    spec.extensions = ["ext/extconf.rb"]
  end

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
