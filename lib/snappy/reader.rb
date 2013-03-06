module Snappy
  class Reader
    attr_reader :io, :magic, :default_version, :minimum_compatible_version

    def initialize(io)
      @io = io
      @io.set_encoding Encoding::ASCII_8BIT unless RUBY_VERSION =~ /^1\.8/
      read_header!
      yield self if block_given?
    end

    def each
      until @io.eof?
        size = @chunked ? @io.read(4).unpack("N").first : @io.length
        yield Snappy.inflate(@io.read(size)) if block_given?
      end
    end

    def read
      @buff = StringIO.new
      each do |chunk|
        @buff << chunk
      end
      @buff.string
    end

    def each_line(sep_string=$/)
      last = ""
      each do |chunk|
        chunk = last + chunk
        lines = chunk.split(sep_string)
        last = lines.pop
        lines.each do |line|
          yield line if block_given?
        end
      end
      yield last
    end

    private

    def read_header!
      magic_byte = @io.readchar
      @io.ungetc(magic_byte)

      if @io.length >= 16 && magic_byte == Snappy::Writer::MAGIC[0]
        @magic, @default_version, @minimum_compatible_version = @io.read(16).unpack("a8NN")
        @chunked = true
      else
        @chunked = false
      end
    end
  end
end
