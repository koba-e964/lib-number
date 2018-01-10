require_relative './gcd.rb'
require_relative './number_util.rb'

# It is promised that p is a prime.
def quad_res_rat(a,p)
  if p % 2 == 0
    if p != 2
      return nil
    end
    r = a % 8
    if r % 2 == 0	
      return 0
    elsif r == 7
      return 1
    else
      return -1
    end
  end
  r = NumberUtil::modPower(a, (p-1)/2, p)
  return r == p - 1 ? -1 : r
end


def kronecker_symbol(a, b)
  tbl = [0, 1, 0, -1, 0, -1, 0, 1]
  s = 1
  if b == 0
    return a * a == 1 ? 1 : 0
  end
  if b < 0
    if a < 0
      s = -1
    end
    b = -b
  end
  v = 0
  if a % 2 == 0 && b % 2 == 0
    return 0
  end
  while b % 2 == 0
    b /= 2
    v = 1 - v
  end
  if (v == 1)
    s *= tbl[a % 8]
  end
  while true
    v = 0
    a %= b
    if a == 0
      break
    end
    while a % 2 == 0
      a /= 2
      v = 1 - v
    end
    if (v == 1)
      s *= tbl[b % 8]
    end
    if (a & b & 3) == 3
      s = -s
    end
    r = a
    a = b
    b = r
  end
  return b == 1 ? s : 0
end
