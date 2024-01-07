# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "snappy/version"

Gem::Specification.new do |spec|
  spec.name          = "snappy"
  spec.version       = Snappy::VERSION
  spec.authors       = ["miyucy"]
  spec.email         = ["fistfvck@gmail.com"]
  spec.description   = "libsnappy binding for Ruby"
  spec.summary       = "libsnappy binding for Ruby"
  spec.homepage      = "http://github.com/miyucy/snappy"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.test_files    = `git ls-files -z -- test`.split("\x0")
  spec.files         = `git ls-files -z`.split("\x0")
  spec.files        -= spec.test_files
  spec.files        -= ["vendor/snappy"]
  spec.files        += Dir["vendor/snappy/**/*"].reject { |e| e.start_with? "vendor/snappy/testdata" }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if defined?(JRUBY_VERSION)
    spec.files += %w[lib/snappy_ext.jar]
    spec.platform = "java"
    spec.add_dependency "snappy-jars", "~> 1.1.0"
  else
    spec.extensions = ["ext/extconf.rb"]
    spec.metadata['msys2_mingw_dependencies'] = 'snappy'
  end
end
