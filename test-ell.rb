require 'test/unit'
require_relative './ell.rb'
require_relative './prime.rb'

class TestElliptic < Test::Unit::TestCase
  def test_projective_multiplication_random()
    for trial in 0..499
      p = getRandomPrime 30
      curve=[p,101]
      point=[rand(p), rand(p)]
      num=rand(p)
      res1=mul(curve,point,num)
      res2=proMul(curve,toPro(point),num)
      assert(npEqual(curve,res1,res2),
	     "not equal, #{point}*#{num},#{res1}!=#{res2}")
    end
  end
  def test_projective_doubling_random()
    for trial in 0..499
      p = getRandomPrime 30
      curve=[p, 101]
      point=[rand(p), rand(p)]
      res1=mul(curve, point, 2)
      res2=proDouble(curve, toPro(point))
      assert(npEqual(curve,res1,res2),
	     "not equal, #{point}*2,#{res1}!=#{res2}")
    end
  end
end
