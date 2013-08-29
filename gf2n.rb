def gf2n_mul(a,b)
	if(a<0||b<0)
		raise
	end
	sum=0
	while b>0
		if(b%2==1)
			sum^=a
		end
		b/=2
		a*=2
	end
	sum
end

include Math

def gf2n_div(a,b)
	if(a<0||b<=0)
		raise
	end
	q=0
	sb=log2(b).to_i()
	th=1<<sb
	while(a>=th)
		sa=log2(a).to_i()
		a^=b<<(sa-sb)
		q^=1<<(sa-sb)
	end
	return [q,a] #quotient,remainder
end

def gf2n_pow(a,n)
	if(n<0)
		raise
	end
	s=1
	c=a
	while(n>0)
		if(n%2==1)
			s=gf2n_mul(s,c)
		end
		c=gf2n_mul(c,c)
		n/=2
	end
	return s
end

def gf2n_pow_mod(a,n,mod)
	if(n<0)
		raise
	end
	s=1
	c=a
	while(n>0)
		if(n%2==1)
			s=gf2n_mul(s,c)
			s=gf2n_div(s,mod)[1]
		end
		c=gf2n_mul(c,c)
		c=gf2n_div(c,mod)[1]
		n/=2
	end
	return s
end

class GF2Poly
	attr_accessor :val
	def initialize(val)
		self.val=val
	end
	def add(ano)
		return GF2Poly.new(self.val^ano.val)
	end
	def mul(ano)
		return GF2Poly.new(gf2n_mul(self.val,ano.val))
	end
	def div(ano)
		res=gf2n_div(self.val,ano.val)
		return [GF2Poly.new(res[0]),GF2Poly.new(res[1])]
	end
	def pow(n)
		return GF2Poly.new(gf2n_pow(self.val,n))
	end
	def to_s()
		return format("Poly[%x]",self.val)
	end
end

def isPrime(poly)
	val=poly.val
	sn=log2(val).to_i
	for i in 2..1<<(sn/2+1)
		if(gf2n_div(val,i)[1]==0)
			return false
		end
	end
	return true
end

def exponent(a,mod)
	sm=log2(mod)
	s=a
	cnt=1
	while(s!=1 && cnt<(1<<sm))
		s=gf2n_mul(s,a)
		s=gf2n_div(s,mod)[1]
		cnt+=1
	end
	if(cnt>=(1<<sm))
		raise Exception("Error:too large exponent")
	end
	return cnt
end
