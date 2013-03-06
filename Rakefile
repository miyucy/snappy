require "bundler/gem_tasks"
require "rake/testtask"
require "rbconfig"

DLEXT = RbConfig::CONFIG["DLEXT"]

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

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end
task :test => "ext/snappy.#{DLEXT}"
