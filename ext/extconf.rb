require 'mkmf'
require 'fileutils'

def try_configure
  return if system "./configure --disable-option-checking --disable-dependency-tracking --disable-gtest --without-gflags"

  if try_run 'int main(int argc, char** argv){ return __builtin_expect(1, 1) ? 0 : 1; }'
    $defs << '-DHAVE_BUILTIN_EXPECT'
  end

  if try_run 'int main(int argc, char** argv){ return (__builtin_ctzll(0x100000000LL) == 32) ? 0 : 1; }'
    $defs << '-DHAVE_BUILTIN_CTZ'
  end

  have_header 'dlfcn.h'
  have_header 'inttypes.h'
  have_header 'memory.h'
  have_header 'stddef.h'
  have_header 'stdint.h'
  have_header 'stdlib.h'
  have_header 'strings.h'
  have_header 'string.h'
  have_header 'sys/mman.h'
  have_header 'sys/stat.h'
  have_header 'sys/types.h'
  have_header 'sys/resource.h'
  have_header 'unistd.h'

  if try_run 'int main(int argc, char** argv){ int i = 1; return *((char*)&i); }'
    $defs << '-DWORDS_BIGENDIAN'
  end
end

unless have_library 'snappy'
  dst = File.dirname File.expand_path __FILE__

  tar = 'tar'
  tar = 'gnutar' if find_executable 'gnutar'

  ver = "1.0.1"
  src = "snappy-#{ver}"

  FileUtils.rm_rf File.join dst, src
  system "curl -s http://snappy.googlecode.com/files/#{src}.tar.gz | #{tar} xz"

  src = File.join dst, src

  Dir.chdir src do
    try_configure
  end

  %w(
config.h
snappy-internal.h
snappy-sinksource.cc
snappy-sinksource.h
snappy-stubs-internal.cc
snappy-stubs-internal.h
snappy.cc
snappy.h
  ).each do |file|
    FileUtils.copy File.join(src, file), File.join(dst, file) if FileTest.exist? File.join(src, file)
  end

  hdr = File.open(File.join(src, 'snappy-stubs-public.h.in'), 'rb'){ |f| f.read }
  {
    %r'#if @ac_cv_have_stdint_h@' => '#ifdef HAVE_STDINT_H',
    %r'#if @ac_cv_have_stddef_h@' => '#ifdef HAVE_STDDEF_H',
    %r'@SNAPPY_MAJOR@'            => '1',
    %r'@SNAPPY_MINOR@'            => '0',
    %r'@SNAPPY_PATCHLEVEL@'       => '1',
  }.each { |ptn, str| hdr.gsub! ptn, str }
  File.open(File.join(dst, 'snappy-stubs-public.h'), 'wb'){ |f| f.write hdr }

  FileUtils.touch 'config.h'
end

have_library 'stdc++'
create_makefile 'snappy'
