def gcd(a,b)
  if b<0
    b=-b
  end
  while b!=0
    r=a%b
    if 2*r>b
      r=b-r
    end
    a=b
    b=r
  end
  a
end

#returns [g,x] such that g=gcd(a,b) and a*x==g (mod b)
def ext_gcd(a,b)
  if b<0
    b=-b
  end
  oldb=b
  g0=1
  g1=0
  while b!=0
    r=a%b
    q=a/b
    a=b
    b=r
    g0,g1=g1,g0-q*g1
    g0%=oldb
    g1%=oldb
  end
  return [a,g0%(oldb/a)]
end

def binary_gcd(a, b)
  if a == 0
    return b
  end
  if b == 0
    return a
  end
  a = a.abs
  b = b.abs
  shift = 0
  while (((a | b) & 1) == 0)
    a >>= 1
    b >>= 1
    shift += 1
  end
  while ((a & 1) == 0)
    a >>= 1
  end
  while b != 0
    while (b & 1) == 0; b >>= 1; end
    if a > b
      t = a
      a = b
      b = t
    end
    b -= a
  end
  return a << shift
end

