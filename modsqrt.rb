require_relative './prime.rb'
require_relative './reci.rb'

def modsqrt(a,p)
  if p<0
    p=-p
  end
  if !mr_prime(p)
    puts "Error: p="+p.to_s+" is not prime."
    return nil
  end
  a%=p
  if a==0
    return 0
  end
  if p==2
    return a
  end
  # p >= 3
  if quad_res_rat(a,p)==-1
    puts "Error: ("+a.to_s+"/"+p.to_s+")=-1"
    return nil
  end
  b=1
  while quad_res_rat(b,p)==1
    b+=1
  end
  e=0
  m=p-1
  while(m%2==0)
    m/=2
    e+=1
  end
  x=modPower(a,(m-1)/2,p)
  y=(a*(x*x%p))%p
  x*=a;x%=p
  z=modPower(b,m,p)
  while(y!=1)
    j=0
    t=y
    while(t!=1)
      j+=1
      t=(t*t)%p
    end
    raise "j>=e" unless j<e
    z=modPower(z,1<<(e-j-1),p)
    x=(x*z)%p
    z=(z*z)%p
    y=(y*z)%p
    e=j
  end
  return x
end

