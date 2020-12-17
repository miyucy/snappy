# frozen_string_literal: true

require "test_helper"
require "stringio"

class SnappyReaderTest < Test::Unit::TestCase
  def setup
    @buffer = StringIO.new
    Snappy::Writer.new @buffer do |w|
      w << "foo"
      w << "bar"
      w << "baz"
      w << "quux"
    end
    @buffer.rewind
  end

  def subject
    @subject ||= Snappy::Reader.new @buffer
  end

  sub_test_case "#initialize" do
    test "should yield itself to the block" do
      yielded = nil
      returned = Snappy::Reader.new @buffer do |r|
        yielded = r
      end
      assert_equal returned, yielded
    end

    test "should read the header" do
      assert_equal Snappy::Writer::MAGIC, subject.magic
      assert_equal Snappy::Writer::DEFAULT_VERSION, subject.default_version
      assert_equal Snappy::Writer::MINIMUM_COMPATIBLE_VERSION, subject.minimum_compatible_version
    end
  end

  sub_test_case :initialize_without_headers do
    def setup
      @buffer = StringIO.new
      @buffer << Snappy.deflate("HelloWorld" * 10)
      @buffer.rewind
    end

    test "should inflate with a magic header" do
      assert_equal "HelloWorld" * 10, subject.read
    end

    test "should not receive `length' in eaching" do
      dont_allow(@buffer).length
      subject.read
    end
  end

  sub_test_case "#io" do
    test "should be a constructor argument" do
      assert_equal @buffer, subject.io
    end

    test "should not receive `length' in initializing" do
      dont_allow(@buffer).length
      Snappy::Reader.new @buffer
    end
  end

  sub_test_case "#each" do
    def setup
      @buffer = StringIO.new
      Snappy::Writer.new @buffer do |w|
        w << "foo"
        w << "bar"
        w.dump!
        w << "baz"
        w << "quux"
      end
      @buffer.rewind
    end

    test "should yield each chunk" do
      chunks = []
      subject.each do |chunk|
        chunks << chunk
      end
      assert_equal %w[foobar bazquux], chunks
    end

    test "should return enumerator w/o block" do
      eacher = subject.each
      assert_instance_of Enumerator, eacher
      chunks = []
      chunks << eacher.next
      chunks << eacher.next
      assert_raise(StopIteration) { eacher.next }
      assert_equal %w[foobar bazquux], chunks
    end
  end

  sub_test_case "#read" do
    test "should return the bytes" do
      assert_equal "foobarbazquux", subject.read
    end
  end

  sub_test_case "#each_line" do
    def setup
      @buffer = StringIO.new
      Snappy::Writer.new @buffer do |w|
        w << "foo\n"
        w << "bar"
        w.dump!
        w << "baz\n"
        w << "quux\n"
      end
      @buffer.rewind
    end

    test "should yield each line" do
      lines = []
      subject.each_line do |line|
        lines << line
      end
      assert_equal %w[foo barbaz quux], lines
    end

    test "should return enumerator w/o block" do
      eacher = subject.each_line
      assert_instance_of Enumerator, eacher
      lines = []
      loop { lines << eacher.next }
      assert_equal %w[foo barbaz quux], lines
    end

    test "each_line split by sep_string" do
      buffer = StringIO.new
      Snappy::Writer.new buffer do |w|
        w << %w[a b c].join(",")
        w.dump!
        w << %w[d e f].join(",")
      end
      buffer.rewind
      reader = Snappy::Reader.new buffer
      eacher = reader.each_line(",")
      lines = []
      loop { lines << eacher.next }
      assert_equal %w[a b cd e f], lines
    end
  end
end
