require_relative "./ell.rb"
require_relative "./prime.rb"
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

def lenstra_elliptic_get_factor(n, debug = 1)
  if mr_prime(n)
    if debug >= 2
      puts "#{n} is a prime"
    end
    return [n]
  end
  b = n.size * n.size * 16
  t = 0
  while true
    if debug >= 1
      puts "Trial #{t}... b = #{b}"
    end
    res = lenstra_elliptic_get_factor_one(n, b, [debug - 1, 0].max)
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
  rem = [n]
  while rem.size >= 1
    q = rem[0]
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
    rem = rem[1 .. -1]
  end
  prime_factors.sort!
  return prime_factors
end

