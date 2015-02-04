require_relative "./ell.rb"
require_relative "./prime.rb"
def lenstra_elliptic_factor_one(n, b = 100, debug = true)
  curve = [n, rand(n)]
  pt = [rand(n), rand(n)]
  cur = pt
  begin
    mul(curve, pt, n)
    for k in 2 .. b
      cur = mul(curve, cur, k)
      if debug
        puts "#{k}! * #{pt} = #{cur}"
      end
    end
  rescue Exception => ex
    f = ex.message.split(" ")[0].to_i
    return [f, n / f]
  end
  if debug
    puts "failure... factor of #{n} was not found"
  end
  return []
end

def lenstra_elliptic_factor(n, trial = 100, debug = true)
  if mr_prime(n)
    if debug
      puts "#{n} is a prime"
    end
    return [n]
  end
  b = n.size * n.size * 16
  for t in 0 ... trial
    res = lenstra_elliptic_factor_one(n, b, debug)
    if res != []
      return res
    end
  end
  return res
end

