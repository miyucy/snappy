require 'mkmf'
require 'fileutils'

unless have_library 'snappy_ext'
  dst = File.dirname File.expand_path __FILE__

  tar = 'tar'
  tar = 'gnutar' if find_executable 'gnutar'

  ver = "1.1.1"
  src = "snappy-#{ver}"

  FileUtils.rm_rf File.join dst, src
  system "curl -s http://snappy.googlecode.com/files/#{src}.tar.gz | #{tar} xz"

  src = File.join dst, src

  Dir.chdir src do
    system "./configure --disable-option-checking --disable-dependency-tracking --disable-gtest --without-gflags"
  end

  %w(
config.h
snappy-c.cc
snappy-c.h
snappy-internal.h
snappy-sinksource.cc
snappy-sinksource.h
snappy-stubs-internal.cc
snappy-stubs-internal.h
snappy-stubs-public.h
snappy.cc
snappy.h
  ).each do |file|
    FileUtils.copy File.join(src, file), File.join(dst, file) if FileTest.exist? File.join(src, file)
  end
end

create_makefile 'snappy_ext'
