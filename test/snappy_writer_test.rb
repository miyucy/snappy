# frozen_string_literal: true

require "test_helper"
require "stringio"

class SnappyWriterTest < Test::Unit::TestCase
  def setup
    @buffer = StringIO.new
  end

  def subject
    @subject ||= Snappy::Writer.new @buffer
  end

  sub_test_case "#initialize" do
    test "should yield itself to the block" do
      yielded = nil
      returned = Snappy::Writer.new @buffer do |w|
        yielded = w
      end
      assert_equal returned, yielded
    end

    test "should write the header" do
      assert_equal [Snappy::Writer::MAGIC,
                    Snappy::Writer::DEFAULT_VERSION,
                    Snappy::Writer::MINIMUM_COMPATIBLE_VERSION].pack("a8NN"), subject.io.string
    end

    test "should dump on the end of yield" do
      Snappy::Writer.new @buffer do |w|
        w << "foo"
      end
      foo = Snappy.deflate "foo"
      assert_equal [foo.size, foo].pack("Na#{foo.size}"), @buffer.string[16, @buffer.size - 16]
    end
  end

  sub_test_case "#io" do
    test "should be a constructor argument" do
      io = StringIO.new
      assert_equal io, Snappy::Writer.new(io).io
    end
  end

  sub_test_case "#block_size" do
    test "should default to DEFAULT_BLOCK_SIZE" do
      assert_equal Snappy::Writer::DEFAULT_BLOCK_SIZE, subject.block_size
    end

    test "should be settable via the constructor" do
      assert_equal 42, Snappy::Writer.new(StringIO.new, 42).block_size
    end
  end
end
