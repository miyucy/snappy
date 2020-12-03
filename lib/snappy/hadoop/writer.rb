# frozen_string_literal: true

require 'snappy/shim'

module Snappy
  module Hadoop
    class Writer
      DEFAULT_BLOCK_SIZE = 256 * 1024

      attr_reader :io, :block_size

      def initialize(io, block_size = DEFAULT_BLOCK_SIZE)
        @block_size = block_size
        @buffer = String.new
        @io = Snappy.set_encoding io
        if block_given?
          yield self
          dump!
        end
      end

      def <<(msg)
        @buffer << msg.to_s
        dump! if @buffer.size >= @block_size
      end

      alias_method :write, :<<

      def dump!
        offset = 0
        while offset < @buffer.size
          uncompressed = @buffer[offset, @block_size]
          compressed = Snappy.deflate(uncompressed)

          # Uncompressed size (32 bit integer, BE), compressed size (32 bit integer, BE), data.
          @io << [uncompressed.size, compressed.size, compressed].pack("NNa#{compressed.size}")
          offset += uncompressed.size
        end

        @io.flush
        @buffer.clear
      end

      alias_method :flush, :dump!

      def close
        @io.close
      end
    end
  end
end
