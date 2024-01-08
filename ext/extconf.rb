require "mkmf"
require "fileutils"

$CXXFLAGS += " -std=c++11 "

have_libsnappy = pkg_config("libsnappy") || have_library("snappy")
unless have_libsnappy
  # build vendor/snappy
  pwd = File.dirname File.expand_path __FILE__
  dir = File.join pwd, "..", "vendor", "snappy"

  Dir.chdir(dir) do
    FileUtils.rm_rf "build"
    FileUtils.mkdir_p "build"
    Dir.chdir(File.join(dir, "build")) do
      `cmake .. -DCMAKE_BUILD_TYPE=Release -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF`
    end
  end

  src = %w[
    config.h
    snappy-stubs-public.h
  ].map { |e| File.join dir, "build", e }
  FileUtils.cp src, pwd, verbose: true
  src = %w[
    snappy-c.cc
    snappy-c.h
    snappy-internal.h
    snappy-sinksource.cc
    snappy-sinksource.h
    snappy.cc
    snappy.h
    snappy-stubs-internal.cc
    snappy-stubs-internal.h
  ].map { |e| File.join dir, e }
  FileUtils.cp src, pwd, verbose: true
end

create_makefile "snappy_ext"
