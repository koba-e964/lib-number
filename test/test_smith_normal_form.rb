require 'test/unit'
require 'smith_normal_form'

class TestSmithNormalForm < Test::Unit::TestCase
  # An example found in https://en.wikipedia.org/wiki/Smith_normal_form#Example
  def test_smith_normal_form_0
    mat = Matrix.rows([[2,4,4], [-6,6,12], [10,-4,-16]])
    snf_expected = Matrix.diagonal(2,6,12)
    result = smith_normal_form(mat)
    assert_equal(snf_expected, result[1])
    assert_equal(mat, result[0] * result[1] * result[2])
  end
end
