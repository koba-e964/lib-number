load './gcd.rb'

def xeucl(a,b)
  x1=1
  x2=0
  y1=0
  y2=1
  if b<0
    b=-b
    y2=-1
  end
  while b!=0
    r=a%b
    q=a/b
    if 2*r>b
      r=b-r
      a=b
      tmp1=y1
      tmp2=y2
      b=r
      y1=(q+1)*tmp1-x1
      y2=(q+1)*tmp2-x2
    else
      a=b
      tmp1=y1
      tmp2=y2
      b=r
      y1=-q*tmp1+x1
      y2=-q*tmp2+x2
    end
    x1=tmp1
    x2=tmp2
  end
  [x1,x2]
end

def crt(a1,m1,a2,m2)
  if gcd(m1,m2)!=1
    return nil
  end
  res=xeucl(m1,m2)
  (a1*res[1]*m2+a2*res[0]*m1)%(m1*m2)
end
