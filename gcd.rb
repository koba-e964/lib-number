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