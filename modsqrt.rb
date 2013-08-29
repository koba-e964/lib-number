load './prime.rb'
load './reci.rb'

def modsqrt(a,p)
  if !mr_prime(p)
    puts "Error: p="+p.to_s+" is not prime."
    return nil
  end
  a%=p
  if a==0
    return 0
  end
  if quad_res_rat(a,p)==-1
    puts "Error: ("+a.to_s+"/"+p.to_s+")=-1"
  end
  b=1
  while quad_res_rat(b,p)==1
    b+=1
  end
end
