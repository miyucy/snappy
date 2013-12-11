require "minitest/autorun"
require "minitest/spec"
require "snappy"

describe Snappy do
  T = [*"a".."z", *"A".."Z", *"0".."9"]

  it "well done" do
    s = Array.new(1024){T.sample}.join
    Snappy.inflate(Snappy.deflate s).must_equal(s)
  end

  it "well done (pair)" do
    s = Array.new(1024){T.sample}.join
    [
     [:deflate,  :inflate],
     [:compress, :uncompress],
     [:dump,     :load],
    ].each do |(i, o)|
      Snappy.__send__(o, (Snappy.__send__ i,  s)).must_equal(s)
      eval %{Snappy.#{o}(Snappy.#{i} s).must_equal(s)}
    end
  end
end
