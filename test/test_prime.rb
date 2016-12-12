require 'test/unit'
require_relative '../prime.rb'
require 'timeout'

class TestPrime < Test::Unit::TestCase
  def test_factorize
    assert_equal([], factorize(1))
    assert_equal([[2, 3], [3, 1]], factorize(24))
    assert_equal([[-1, 1], [2, 3], [3, 1]], factorize(-24))
    assert_equal([[1000000007, 1]], factorize(1000000007))
  end
  def try_semiprime(p, q, limit)
    assert_equal([[p, 1], [q, 1]], Timeout.timeout(limit){
                   factorize(p * q)
                 })
  end
  def test_factorize_semiprime
    try_semiprime(997, 1019, 1.0)
    try_semiprime(18743117, 26496641, 4.0)
  end
end
