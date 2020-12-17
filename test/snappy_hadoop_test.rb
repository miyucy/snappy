# frozen_string_literal: true

require "test_helper"
require "stringio"

class SnappyHadoopTest < Test::Unit::TestCase
  T = [*"a".."z", *"A".."Z", *"0".."9"].freeze

  def random_data(length = 1024)
    Array.new(length) { T.sample }.join
  end

  test "well done" do
    s = random_data
    assert_equal s, Snappy::Hadoop.inflate(Snappy::Hadoop.deflate(s))
  end

  test "well done(pair)" do
    s = random_data
    [
      %i[deflate inflate]
    ].each do |(i, o)|
      assert_equal s, Snappy::Hadoop.__send__(o, Snappy::Hadoop.__send__(i, s))
    end
  end
end
