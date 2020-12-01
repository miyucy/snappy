# Snappy ![](https://travis-ci.org/miyucy/snappy.svg?branch=master)

see https://github.com/google/snappy

## Preparation


### macOS

```bash
$ brew install snappy
$ brew install autoconf automake libtool
```

### Ubuntu

```bash
$ apt-get install libsnappy-dev -y
$ apt-get install libtool automake autoconf -y
```

### Alpine

```bash
$ apk install snappy
$ apk install build-base libexecinfo automake autoconf libtool
```

## Installation

Add this line to your application's Gemfile:

    gem 'snappy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install snappy

## Usage

Snappy-java format
```ruby
require 'snappy'

Snappy.deflate(source)
# => Compressed data

Snappy.inflate(source)
# => Decompressed data
```

Hadoop-snappy format
```ruby
Snappy::Hadoop.deflate(source)
# => Compressed data

Snappy::Hadoop.inflate(source)
# => Decompressed data
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
