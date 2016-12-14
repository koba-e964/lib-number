require 'test/unit'
require 'intbasis.rb'


class TestIntBasis < Test::Unit::TestCase
  def row_vec_mat_mul_mod(row_vec, mat, mod)
    n = row_vec.size
    assert_equal(n, mat.size)
    m = mat[0].size
    result = Array.new(m, 0)
    for i in 0 ... m
      for j in 0 ... n
        result[i] += row_vec[j] * mat[j][i]
        result[i] = result[i] % mod
      end
    end
    result
  end

  def test_kernel_mod_0
    ary = [[1, 1], [1, 1], [1, 1]]
    p = 2
    kernel = kernel_mod(ary, p)
    for row_vec in kernel
      assert_equal(Array.new(2, 0), row_vec_mat_mul_mod(row_vec, ary, p))
    end
  end

  def test_kernel_mod_1
    ary = [[1, 1, 2], [1, 0, 1], [1, 2, 0]]
    p = 3
    kernel = kernel_mod(ary, p)
    for row_vec in kernel
      assert_equal(Array.new(3, 0), row_vec_mat_mul_mod(row_vec, ary, p))
    end
  end

  def test_kernel_mod_2
    ary = [[2, 1, -1, 2, 1, -1, 3, 0, 0], [2, 1, -1, 8, 4, -4, 0, 3, 0], [3, 0, 0, 0, 3, 0, 0, 0, 0]]
    p = 3
    kernel = kernel_mod(ary, p)
    for row_vec in kernel
      assert_equal(Array.new(9, 0), row_vec_mat_mul_mod(row_vec, ary, p))
    end
  end
end
