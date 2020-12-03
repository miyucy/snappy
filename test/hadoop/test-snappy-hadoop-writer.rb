require "minitest/autorun"
require "minitest/spec"
require "snappy"
require "stringio"

describe Snappy::Hadoop::Writer do
  before do
    @buffer = StringIO.new
  end

  subject do
    Snappy::Hadoop::Writer.new @buffer
  end

  describe :initialize do
    it "should yield itself to the block" do
      yielded = nil
      returned = Snappy::Hadoop::Writer.new @buffer do |w|
        yielded = w
      end
      returned.must_equal yielded
    end

    it "should dump on the end of yield" do
      Snappy::Hadoop::Writer.new @buffer do |w|
        w << "foo"
      end
      @buffer.string.must_equal "\u0000\u0000\u0000\u0003\u0000\u0000\u0000\u0005\u0003\bfoo"
    end
  end

  describe :io do
    it "should be a constructor argument" do
      io = StringIO.new
      Snappy::Hadoop::Writer.new(io).io.must_equal io
    end
  end

  describe :block_size do
    it "should default to DEFAULT_BLOCK_SIZE" do
      Snappy::Hadoop::Writer.new(StringIO.new).block_size.must_equal Snappy::Hadoop::Writer::DEFAULT_BLOCK_SIZE
    end

    it "should be settable via the constructor" do
      Snappy::Hadoop::Writer.new(StringIO.new, 42).block_size.must_equal 42
    end
  end
end
