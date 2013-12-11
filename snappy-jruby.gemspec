# coding: utf-8

spec = load(File.expand_path('../snappy.gemspec', __FILE__))
spec.platform = 'java'
spec.extensions = nil
spec.files += Dir['lib/snappy_ext.jar']
spec.add_dependency 'snappy-jars', '~> 1.1.0'
spec