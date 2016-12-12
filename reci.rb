require_relative './gcd.rb'
require_relative './prime.rb'

def quad_res_rat(a,p)
	if p%2==0
		if p==2
			r=a%8
			if r%2==0	
				return 0
			elsif r==-1 || r==7
				return 1
			else
				return -1
			end
		else
			return nil
		end
	end
	r=modPower(a,(p-1)/2,p)
	if r==p-1
		return -1
	else
		return r
	end
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
  return (if b == 1 then s else 0 end)
end
