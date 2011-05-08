require 'mkmf'
require 'fileutils'

unless have_library 'snappy'
  have_header 'sys/mman.h'

  have_header 'stdint.h'

  have_header 'stddef.h'

  if try_run 'int main(int argc, char** argv){ return __builtin_expect(1, 1) ? 0 : 1; }'
    $defs << '-DHAVE_BUILTIN_EXPECT'
  end

  if try_run 'int main(int argc, char** argv){ return (__builtin_ctzll(0x100000000LL) == 32) ? 0 : 1; }'
    $defs << '-DHAVE_BUILTIN_CTZ'
  end

  dst = File.dirname File.expand_path __FILE__

  ver = "1.0.1"
  src = "snappy-#{ver}"
  FileUtils.rm_rf src

  system "curl -s http://snappy.googlecode.com/files/#{src}.tar.gz | tar xz"

  %w(
snappy-internal.h
snappy-sinksource.cc
snappy-sinksource.h
snappy-stubs-internal.cc
snappy-stubs-internal.h
snappy.cc
snappy.h
  ).each do |file|
    FileUtils.copy File.join(src, file), File.join(dst, file)
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

end

have_library 'stdc++'
create_makefile 'snappy'
