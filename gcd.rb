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
