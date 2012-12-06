require 'rubygems'
require 'bundler'
require 'rbconfig'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

DLEXT = RbConfig::CONFIG['DLEXT']

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "snappy"
  gem.homepage = "http://github.com/miyucy/snappy"
  gem.license = "MIT"
  gem.summary = %Q{libsnappy binding for Ruby}
  gem.description = %Q{libsnappy binding for Ruby}
  gem.email = "miyucy@gmail.com"
  gem.authors = ["miyucy"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "snappy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('ext/**/*.cc')
end

task :spec => "ext/snappy.#{DLEXT}"

file "ext/snappy.#{DLEXT}" => Dir.glob("ext/*{.rb,.c}") do
  Dir.chdir("ext") do
     ruby "extconf.rb"
     sh "make"
  end
  cp "ext/snappy.#{DLEXT}", "lib"
end

task :clean do
  rm_rf(["ext/snappy.#{DLEXT}", "lib/snappy.#{DLEXT}", "ext/mkmf.log", "ext/config.h", "ext/api.o", "ext/Makefile", "ext/snappy.cc", "ext/snappy.h", "ext/snappy.o"] + Dir["ext/snappy-*"])
end