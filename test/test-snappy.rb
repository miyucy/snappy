require "minitest/spec"
require "minitest/autorun"
require "snappy"

describe Snappy do
  T = [*"a".."z", *"A".."Z", *"0".."9"]

  it "well done" do
    s = Array.new(1024){T.sample}.join
    Snappy.inflate(Snappy.deflate s).must_equal(s)
  end
end
