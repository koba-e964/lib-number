require 'test/unit'
require 'reci.rb'
require 'prime_util.rb'

class TestReciprocity < Test::Unit::TestCase
  def test_kronecker_symbol
    assert_equal(1, kronecker_symbol(2, 7))
    assert_equal(1, kronecker_symbol(2, -7))
    assert_equal(-1, kronecker_symbol(11, 13))
    assert_equal(1, kronecker_symbol(-11, -13))
    assert_equal(-1, kronecker_symbol(1001, 9907)) # from https://en.wikipedia.org/wiki/Jacobi_symbol
  end
  def test_kronecker_symbol_0
    assert_equal(0, kronecker_symbol(2, 0))
    assert_equal(1, kronecker_symbol(1, 0))
    assert_equal(0, kronecker_symbol(0, 0))
    assert_equal(1, kronecker_symbol(-1, 0))
    assert_equal(0, kronecker_symbol(-2, 0))
  end
  def test_kronecker_symbol_prime_random
    trial = 200
    for _ in 1 .. trial
      p = getRandomPrime(30)
      a = rand(p)
      assert_equal(quad_res_rat(a, p), kronecker_symbol(a, p))
    end
  end
end

