# frozen_string_literal: true

require "test_helper"
require "stringio"

class SnappyHadoopWriterTest < Test::Unit::TestCase
  def setup
    @buffer = StringIO.new
  end

  def subject
    @subject ||= Snappy::Hadoop::Writer.new @buffer
  end

  sub_test_case "#initialize" do
    test "should yield itself to the block" do
      yielded = nil
      returned = Snappy::Hadoop::Writer.new @buffer do |w|
        yielded = w
      end
      assert_equal returned, yielded
    end

    test "should write the header" do
      Snappy::Hadoop::Writer.new @buffer do |w|
        w << "foo"
      end
      assert_equal "\u0000\u0000\u0000\u0003\u0000\u0000\u0000\u0005\u0003\bfoo", @buffer.string
    end
  end

  sub_test_case "#io" do
    test "should be a constructor argument" do
      io = StringIO.new
      assert_equal io, Snappy::Hadoop::Writer.new(io).io
    end
  end

  sub_test_case "#block_size" do
    test "should default to DEFAULT_BLOCK_SIZE" do
      assert_equal Snappy::Hadoop::Writer::DEFAULT_BLOCK_SIZE, subject.block_size
    end

    test "should be settable via the constructor" do
      assert_equal 42, Snappy::Hadoop::Writer.new(StringIO.new, 42).block_size
    end
  end
end
