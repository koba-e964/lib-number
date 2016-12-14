require 'test/unit'
require 'alg-lin.rb'

class TestAlgLin < Test::Unit::TestCase
  def test_disc_gen_field_0
    # This example is found at http://math.stackexchange.com/questions/297515/find-an-integral-basis-of-mathbbq-alpha-where-alpha3-alpha-4-0
    # Discriminant of x^3 - x - 4
    k = Field.new([-4, -1, 0, 1])
    assert_equal(-428, disc_gen_field(k))
  end
  def test_disc_gen_field_1
    # This example is found at https://en.wikipedia.org/wiki/Discriminant_of_an_algebraic_number_field
    # Discriminant of x^3 - x^2 - 2x - 8
    k = Field.new([-8, -2, -1, 1])
    assert_equal(-503 * 4, disc_gen_field(k))
  end
end
