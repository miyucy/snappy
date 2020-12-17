# frozen_string_literal: true

require "snappy/shim"
require "snappy/writer"

module Snappy
  class Reader
    attr_reader :io, :magic, :default_version, :minimum_compatible_version

    def initialize(io)
      @io = Snappy.set_encoding io
      read_header!
      yield self if block_given?
    end

    def each
      return to_enum unless block_given?

      until @io.eof?
        if @chunked
          size = @io.read(4).unpack1("N")
          yield Snappy.inflate(@io.read(size))
        else
          yield Snappy.inflate(@io.read)
        end
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

    private

    def read_header!
      header = @io.read Snappy::Writer::MAGIC.length
      if header.length == Snappy::Writer::MAGIC.length && header == Snappy::Writer::MAGIC
        @magic, @default_version, @minimum_compatible_version = header, *@io.read(8).unpack("NN")
        @chunked = true
      else
        @io.rewind
        @chunked = false
      end
    end
  end
end
