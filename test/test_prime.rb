require 'test/unit'
require_relative '../prime_util.rb'
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
    try_semiprime(18743117, 26496641, nil)
  end
  def test_prime_semiprime
    # Ten 100-bit prime numbers
    factor_base = [982731230891153517077233520749,
                   664451998196588992770553537109,
                   738955130234353657237963452989,
                   1084919827224585772475482624259,
                   1047816224372892606548366771033,
                   1103341343592365283696947892049,
                   1245373428895684332114563596759,
                   847035519730276667878191297097,
                   709655954925957715076615388101,
                   1158127966728659727624549102397]
    for f in factor_base
      for g in factor_base
        assert_equal(false, mr_prime(f * g))
      end
    end
    for f in factor_base
      for g in factor_base
        for h in factor_base
          assert_equal(false, mr_prime(f * g * h))
        end
      end
    end
  end
  def test_factorize_prime_power
    assert_equal([[9986563, 2]], Timeout.timeout(1.0){
                   factorize(9986563 ** 2)
                 })
  end
  def test_check_power
    assert_equal([9986563, 2], NumberUtil::check_power(9986563 ** 2))
    assert_equal([10, 400], NumberUtil::check_power(10000 ** 100))
    assert_equal([11, 3], NumberUtil::check_power(1331))
    assert_equal([1, 1], NumberUtil::check_power(1))
    assert_equal([0, 1], NumberUtil::check_power(0))
    assert_equal([7, 1], NumberUtil::check_power(7))
  end
end
