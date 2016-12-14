require 'test/unit'
require './modsqrt.rb'

class TestModSqrt < Test::Unit::TestCase
  def test_modsqrt_random
    size=80
    trial=100
    p=getRandomPrime(size)
    for i in 0...trial
      a=rand(p)
      b=modPower(a,2,p)
      x=modsqrt(b,p)
      assert(x==a||x==p-a, "error:x != \pm a")
    end
  end
end
