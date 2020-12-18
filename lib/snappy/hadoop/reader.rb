# frozen_string_literal: true

require 'stringio'
require 'snappy/shim'

module Snappy
  module Hadoop
    class Reader
      attr_reader :io

      def initialize(io)
        @io = Snappy.set_encoding io
        yield self if block_given?
      end

      def each
        return to_enum unless block_given?

        until @io.eof?
          # Uncompressed size (32 bit integer, BE).
          uncompressed_size = @io.read(4).unpack('N').first

          uncompressed_block_io = StringIO.new
          while uncompressed_block_io.size < uncompressed_size
            # Compressed subblock size (32 bit integer, BE).
            compressed_size = @io.read(4).unpack('N').first
            uncompressed_block_io << Snappy.inflate(@io.read(compressed_size))
          end

          if uncompressed_block_io.size > uncompressed_size
            raise RuntimeError("Invalid data: expected #{uncompressed_size} bytes, got #{Uncompressed.size}")
          end

          yield uncompressed_block_io.string
        end
      end

      def read
        buff = StringIO.new
        each do |chunk|
          buff << chunk
        end
        buff.string
      end

      def each_line(sep_string = $/)
        return to_enum(:each_line, sep_string) unless block_given?

        last = ""
        each do |chunk|
          chunk = last + chunk
          lines = chunk.split(sep_string)
          last = lines.pop
          lines.each do |line|
            yield line
          end
        end
        yield last
      end
    end
  end
end
