# Snappy

see http://code.google.com/p/snappy

## Installation

Add this line to your application's Gemfile:

    gem 'snappy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install snappy

## Usage

```ruby
require 'snappy'

Snappy.deflate(source)
# => Compressed data

Snappy.inflate(source)
# => Decompressed data
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
