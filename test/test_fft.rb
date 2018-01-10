require 'test/unit'
require 'fft.rb'

class TestFFT < Test::Unit::TestCase
  def test_schoenhage_strassen_random
    trial=100
    len=1000
    for i in 0 ... trial
      a = rand(1 << len)
      b = rand(1 << len)
      res_ordinary = a * b
      res_schoenhage = schoenhage_strassen(a, b)
      assert_equal(res_ordinary, res_schoenhage,
                   "Error: a = #{a}, b = #{b}")
    end
  end
end
