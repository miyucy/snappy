# frozen_string_literal: true

require 'snappy/shim'

module Snappy
  class Writer
    MAGIC = Snappy.b("\x82SNAPPY\x0")
    DEFAULT_VERSION = 1
    MINIMUM_COMPATIBLE_VERSION = 1
    DEFAULT_BLOCK_SIZE = 32 * 1024

    attr_reader :io, :block_size

    def initialize(io, block_size = DEFAULT_BLOCK_SIZE)
      @block_size = block_size
      @buffer = String.new
      @io = Snappy.set_encoding io
      write_header!
      if block_given?
        yield self
        dump!
      end
    end

    def <<(msg)
      @buffer << msg.to_s
      dump! if @buffer.size > @block_size
    end

    alias_method :write, :<<

    def dump!
      compressed = Snappy.deflate(@buffer)
      @io << [compressed.size, compressed].pack("Na#{compressed.size}")
      @io.flush
      @buffer.clear
    end

    alias_method :flush, :dump!

    def close
      @io.close
    end

    private

    def write_header!
      @io << [MAGIC, DEFAULT_VERSION, MINIMUM_COMPATIBLE_VERSION].pack("a8NN")
    end
  end
end
