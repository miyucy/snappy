require "spec_helper"

module Snappy
  describe Writer do
    before do
      @buffer = StringIO.new
    end

    subject do
      Writer.new @buffer
    end

    describe :initialize do
      it "should yield itself to the block" do
        yielded = nil
        returned = Writer.new @buffer do |w|
          yielded = w
        end
        returned.should == yielded
      end

      it "should write the header" do
        subject.io.string.should == [Writer::MAGIC, Writer::DEFAULT_VERSION, Writer::MINIMUM_COMPATIBLE_VERSION].pack("a8NN")
      end

      it "should dump on the end of yield" do
        Writer.new @buffer do |w|
          w << "foo"
        end
        foo = Snappy.deflate "foo"
        @buffer.string[16, @buffer.size - 16].should == [foo.size, foo].pack("Na#{foo.size}")
      end
    end

    describe :io do
      it "should be a constructor argument" do
        io = StringIO.new
        Writer.new(io).io.should == io
      end
    end

    describe :block_size do
      it "should default to DEFAULT_BLOCK_SIZE" do
        Writer.new(StringIO.new).block_size.should == Writer::DEFAULT_BLOCK_SIZE
      end

      it "should be settable via the constructor" do
        Writer.new(StringIO.new, 42).block_size.should == 42
      end
    end
  end
end