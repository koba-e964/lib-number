require 'test/unit'
require_relative '../ell.rb'

class TestElliptic < Test::Unit::TestCase
  def test_projective_multiplication_random()
    for trial in 0..499
      p = getRandomPrime 30
      curve = EllipticCurve.new(p, 101)
      point=[rand(p), rand(p)]
      num=rand(p)
      res1 = curve.affine_mul(point, num)
      res2 = curve.projective_mul(affine_to_projective(point), num)
      assert(curve.affine_projective_equal(res1, res2),
	     "not equal, #{point}*#{num},#{res1}!=#{res2}")
    end
  end
  def test_projective_doubling_random()
    for trial in 0..499
      p = getRandomPrime 30
      curve = EllipticCurve.new(p, 101)
      point=[rand(p), rand(p)]
      res1 = curve.affine_mul(point, 2)
      res2 = curve.projective_double(affine_to_projective(point))
      assert(curve.affine_projective_equal(res1, res2),
	     "not equal, #{point}*2,#{res1}!=#{res2}")
    end
  end
end
