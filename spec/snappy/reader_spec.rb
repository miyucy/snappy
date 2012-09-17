require "spec_helper"

module Snappy
  describe Reader do
    before do
      @buffer = StringIO.new
      Writer.new @buffer do |w|
        w << "foo"
        w << "bar"
        w << "baz"
        w << "quux"
      end
      @buffer.rewind
    end

    subject do
      Reader.new @buffer
    end

    describe :initialize do
      it "should yield itself to the block" do
        yielded = nil
        returned = Reader.new @buffer do |r|
          yielded = r
        end
        returned.should == yielded
      end

      it "should read the header" do
        subject.magic.should == Writer::MAGIC
        subject.default_version.should == Writer::DEFAULT_VERSION
        subject.minimum_compatible_version == Writer::MINIMUM_COMPATIBLE_VERSION
      end
    end

    describe :initialize_without_headers do
      before do
        @buffer = StringIO.new
        @buffer << Snappy.deflate("HelloWorld" * 10)
        @buffer.rewind
      end

      it "should inflate with a magic header" do
        subject.read.should == ("HelloWorld" * 10)
      end
    end

    describe :io do
      it "should be a constructor argument" do
        subject.io.should == @buffer
      end
    end

    describe :each do
      before do
        Writer.new @buffer do |w|
          w << "foo"
          w << "bar"
          w.dump!
          w << "baz"
          w << "quux"
        end
        @buffer.rewind
      end

      it "should yield each chunk" do
        chunks = []
        Reader.new(@buffer).each do |chunk|
          chunks << chunk
        end
        chunks.should == ["foobar", "bazquux"]
      end
    end

    describe :read do
      before do
        Writer.new @buffer do |w|
          w << "foo"
          w << "bar"
          w << "baz"
          w << "quux"
        end
        @buffer.rewind
      end

      it "should return the bytes" do
        Reader.new(@buffer).read.should == "foobarbazquux"
      end
    end

    describe :each_line do
      before do
        Writer.new @buffer do |w|
          w << "foo\n"
          w << "bar"
          w.dump!
          w << "baz\n"
          w << "quux\n"
        end
        @buffer.rewind
      end

      it "should yield each line" do
        lines = []
        Reader.new(@buffer).each_line do |line|
          lines << line
        end
        lines.should == ["foo", "barbaz", "quux"]
      end
    end
  end
end