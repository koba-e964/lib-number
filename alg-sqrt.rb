require_relative 'field.rb'
require_relative 'modsqrt.rb'


def alg_sqrt_base(k,a,p)  # k:field, a:algebraic integer in k, p:rational prime
	# (p) must be prime ideal in k.
	d=k.dim()
	for i in 0...p**d
		ary=Array.new(d)
		v=i
		for j in 0...d
			ary[j]=v%p
			v/=p
		end
		if k.eq(k.power_mod(ary,2,p),k.mod(a,p))
			return ary
		end
	end
	raise Exception.new("a is not square")
end

def alg_sqrt_base_3(k,a,p)  # k:field, a:algebraic integer in k, p:rational prime
	# (p) must be prime ideal in k.
	if p%4!=3
		raise Exception.new("p!=3 (mod 4)")
	end
	d=k.dim()
	if d%2!=1
		raise Exception.new("2|d")
	end
	exp=(p**d-1)/(p-1)+1
	exp/=2
	na=k.norm(a) #-----------------TODO  k.norm(eta) for arbitrary eta
	p na
	b=modsqrt(na,p)
	beta=k.power_mod(a,exp,p)
	binv=ext_gcd(b,p)[1]
	beta=k.mult_mod(beta,[binv],p)
	return beta
end

