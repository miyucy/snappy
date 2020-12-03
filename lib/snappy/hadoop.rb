# encoding: utf-8
# frozen_string_literal: true

require 'stringio'
require 'snappy/hadoop/reader'
require 'snappy/hadoop/writer'

module Snappy
  module Hadoop
    def self.deflate(source, block_size = Snappy::Hadoop::Writer::DEFAULT_BLOCK_SIZE)
      compressed_io = StringIO.new
      writer = Snappy::Hadoop::Writer.new(compressed_io)
      writer << source
      writer.flush
      compressed_io.string
    end

    def self.inflate(source)
      Snappy::Hadoop::Reader.new(StringIO.new(source)).read
    end
  end
end
