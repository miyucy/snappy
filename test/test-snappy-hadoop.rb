require 'minitest/autorun'
require 'minitest/spec'
require 'snappy'

describe Snappy::Hadoop do
  T = [*'a'..'z', *'A'..'Z', *'0'..'9']

  it 'well done' do
    s = Array.new(1024){T.sample}.join
    Snappy::Hadoop.inflate(Snappy::Hadoop.deflate s).must_equal(s)
  end

  it 'well done (pair)' do
    s = Array.new(1024){T.sample}.join
    [
     [:deflate,  :inflate],
    ].each do |(i, o)|
      Snappy::Hadoop.__send__(o, (Snappy::Hadoop.__send__ i,  s)).must_equal(s)
      eval %{Snappy::Hadoop.#{o}(Snappy::Hadoop.#{i} s).must_equal(s)}
    end
  end
end
