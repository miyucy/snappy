# frozen_string_literal: true

require "test_helper"

class SnappyTest < Test::Unit::TestCase
  T = [*"a".."z", *"A".."Z", *"0".."9"].freeze

  def random_data(length = 1024)
    Array.new(length) { T.sample }.join
  end

  test "VERSION" do
    assert do
      ::Snappy.const_defined?(:VERSION)
    end
  end

  test "well done" do
    s = random_data
    assert_equal s, Snappy.inflate(Snappy.deflate(s))
  end

  test "well done (pair)" do
    s = random_data
    [
      %i[deflate inflate],
      %i[compress uncompress],
      %i[dump load]
    ].each do |(i, o)|
      assert_equal s, Snappy.__send__(o, Snappy.__send__(i, s))
    end
  end

  sub_test_case ".deflate" do
    test "can pass buffer" do
      if defined? JRUBY_VERSION
        notify "cannot pass buffer in jruby"
        omit
      end
      s = random_data
      d = " " * 1024
      r = Snappy.deflate(s, d)
      assert_equal r.object_id, d.object_id
    end
  end

  sub_test_case ".inflate" do
    test "can pass buffer" do
      if defined? JRUBY_VERSION
        notify "cannot pass buffer in jruby"
        omit
      end
      s = Snappy.deflate(random_data)
      d = " " * 1024
      r = Snappy.inflate(s, d)
      assert_equal r.object_id, d.object_id
    end
  end

  sub_test_case ".valid?" do
    test "return true when passed deflated data" do
      if defined? JRUBY_VERSION
        notify "snappy-jars does not have valid?"
        omit
      end
      d = Snappy.deflate(random_data)
      assert_true Snappy.valid?(d)
    end

    test "return false when passed invalid data" do
      if defined? JRUBY_VERSION
        notify "snappy-jars does not have valid?"
        omit
      end
      d = Snappy.deflate(random_data).reverse
      assert_false Snappy.valid?(d)
    end
  end

  sub_test_case "Ractor safe" do
    test "able to invoke non-main ractor" do
      unless defined? ::Ractor
        notify "Ractor not defined"
        omit
      end
      s = random_data
      a = Array.new(2) do
        Ractor.new(s) do |s|
          Snappy.inflate(Snappy.deflate(s)) == s
        end
      end
      assert_equal [true, true], a.map(&:take)
    end
  end
end
