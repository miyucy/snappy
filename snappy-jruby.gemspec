# coding: utf-8

begin
  spec = eval(File.read(File.expand_path('../snappy.gemspec', __FILE__)))
  spec.platform = 'java'
  spec.extensions = nil
  spec.files += Dir['lib/snappy_ext.jar']
  spec.add_dependency 'snappy-jars', '~> 1.1.0'
  spec
rescue => e
  puts e.message
  puts e.backtrace
  raise e
end