load 'field.rb'

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
