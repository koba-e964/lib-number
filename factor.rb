require_relative "./ell.rb"
require_relative "./prime_util.rb"
def lenstra_elliptic_get_factor_one(n, b = 100, debug = 1)
  curve = [n, rand(n)]
  pt = [rand(n), rand(n)]
  cur = pt
  ctrial = 0
  begin
    mul(curve, pt, n)
    for k in 2 .. b
      ctrial = k
      cur = mul(curve, cur, k)
      if debug >= 2
        puts "#{k}! * #{pt} = #{cur}"
      end
    end
  rescue => ex
    f = ex.message.split(" ")[0].to_i
    if f >= 2 && f < n
      if debug >= 1
        puts "Found factor #{f} in computation of #{ctrial}! * P"
      end
      return [f, n / f]
    end
  end
  if debug >= 2
    puts "failure... factor of #{n} was not found"
  end
  return []
end

def lenstra_elliptic_get_factor_one_pro(n, b = 100, debug = 1)
  curve = EllipticCurve.new(n, rand(n))
  pt = [rand(n), rand(n), 1]
  cur = pt
  ctrial = 0
  
  res = curve.projective_mul(pt, n)
  g = gcd(res[2], n)
  if g >= 2 && g < n
    return [g, n / g]
  end
  for k in 2 .. b
    ctrial = k
    cur = curve.projective_mul(cur, k)
    if debug >= 2
      puts "#{k}! * #{pt} = #{cur}"
    end
    g = gcd(cur[2], n)
    if g >= 2 && g < n
      if debug >= 1
        puts "Found factor #{g} in computation of #{ctrial}! * P"
      end
      return [g, n / g]
    end
  end
  if debug >= 2
    puts "failure... factor of #{n} was not found"
  end
  return []
end

include Math

def lenstra_elliptic_get_factor(n, debug = 1)
  if mr_prime(n)
    if debug >= 2
      puts "#{n} is a prime"
    end
    return [n]
  end
  ch_pow = check_power(n)
  if ch_pow[1] >= 2
    return [ch_pow[0]] * ch_pow[1]
  end
  b = (2.0 ** sqrt(n.size * 8 * log2(n.size))).to_i
  t = 0
  while true
    if debug >= 1
      puts "Trial #{t}... b = #{b}"
    end
    res = lenstra_elliptic_get_factor_one_pro(n, b, [debug - 1, 0].max)
    if res != []
      return res
    end
    t += 1
    b += 4 * n.size
  end
end

def lenstra_elliptic_factorize(n, debug = 1)
  prime_factors = []
  n = n.abs
  if n == 0
    raise Exception.new("lenstra_elliptic_factorize(0)")
  end
  if n == 1
    return []
  end
  rem = [n]
  while rem.size >= 1
    q = rem.shift
    if debug >= 1
      puts "trying #{q}..."
    end
    res = lenstra_elliptic_get_factor(q, [debug - 1, 0].max)
    if res.length == 1
      # q is prime
      prime_factors << q
    else
      rem += res
    end
  end
  prime_factors.sort!
  return prime_factors
end

