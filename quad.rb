load "./prime.rb"
def abs(n)
	if n<0
		-n
	else
		n
	end
end
class QF
	attr_accessor :d
	def initialize(d)
		fc=factorize d
		for c in fc
			if c[1]>=2
				self.d=nil
				return
			end
		end
		self.d=d
	end
	def mul(a,b)
		[ a[0]*b[0]+self.d*a[1]*b[1], a[1]*b[0]+a[0]*b[1] ]
	end
	def norm(a)
		a[0]*a[0]-self.d*a[1]*a[1]
	end
	def add(a,b)
		[ a[0]+b[0],a[1]+b[1] ]
	end
	def sub(a,b)
		[ a[0]-b[0], a[1]-b[1] ]
	end
	def to_alg(a)
		[a,0]
	end
	def conj(a)
		[a[0],-a[1]]
	end
	def div_0(nor,b)
		b[0]%nor==0 && b[1]%nor==0
	end
	def div_1(nor,b)
		[b[0]/nor,b[1]/nor]
	end
	def divisible(a,b) # Checks if a|b 
	# Norm(a)|b*conj(a)
		if a==[0,0]
			return b==[0,0]
		end
		div_0(self.norm(a), self.mul(self.conj(a),b))
	end
	def divide_if(b,a)
		if a==[0,0]
			return nil
		end
		n=self.norm(a)
		cab=self.mul(self.conj(a),b)
		if div_0(n,cab)
			div_1(n,cab)
		else
			nil
		end
	end
	def is_unit(a)
		n=field.norm(a)
		n==1 || n==-1
	end
	def is_prime(a)
		n=self.norm(a)
		if n<0
			n=-n
		end
		mr_prime(n)
	end
	def prime_decomp(qfb,p) # (d/p)=1 <==> p‚Í2‚Â‚É•ª‰ð‚³‚ê‚é
		if (4*d)%p==0
			return nil
		end
		l=legendre(d,p)
		if l==-1
			return [[p,0],1]
		end
		# p | r^2-d
		r=0
		for r in 0..(p-1)/2
			if (r*r-d)%p==0
				break
			end
		end
		puts "r=#{r}, #{p}|r^2-#{d}"
		res=qfb.factorize([r,1])
		if res[0]==nil && mr_prime(abs(self.norm(res[1])))
			return res[1]
		end
		return nil
	end
end
def legendre(a,p)
	a%=p
	e=(p-1)/2
	s=1
	c=a
	while e>0
		if(e%2==1)
			s*=c
			s%=p
		end
		c*=c
		c%=p
		e/=2
	end
	if s==p-1 then -1 else s end
end
