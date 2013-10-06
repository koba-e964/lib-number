module GF2n
	module_function
	def multiply(a,b)
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

	def divide(a,b)
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
	
	def power(a,n)
		if(n<0)
			raise
		end
		s=1
		c=a
		while(n>0)
			if(n%2==1)
				s=multiply(s,c)
				end
				c=multiply(c,c)
				n/=2
			end
			return s
		end
		
	def power_mod(a,n,mod)
		if(n<0)
			raise
		end
		s=1
		c=a
		while(n>0)
			if(n%2==1)
				s=multiply(s,c)
				s=divide(s,mod)[1]
			end
			c=multiply(c,c)
			c=divide(c,mod)[1]
			n/=2
		end
		return s
	end
	def isPrime(poly)
		raise Exception unless poly.is_a?GF2Poly
		val=poly.val
		if(val==0)
			return false
		end
		sn=log2(val).to_i
		if sn==0
			return false
		end
		for i in 2..1<<(sn/2+1)
			if i==val
				next
			end
			if(divide(val,i)[1]==0)
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
			s=multiply(s,a)
			s=divide(s,mod)[1]
			cnt+=1
		end
		if(cnt>=(1<<sm))
			raise Exception("Error:too large exponent")
		end
		return cnt
	end

	def get_prime(deg)
		trial=0
		while(trial<deg*10)
			x=rand(1<<deg)
			x+=1<<deg
			x|=1
			po=GF2Poly.new(x)
			if(po.prime?)
				return po
			end
		end
		raise Exception.new('not found (deg='+deg.to_s+')')
	end
	
	def test_get_prime_count(deg)
		c=0
		for i in (1<<(deg))...(1<<(deg+1))
			if GF2Poly.new(i).prime?
				c+=1
			end
		end
		return c
	end
end #module GF2n

class GF2Poly
	extend GF2n
	attr_accessor :val
	def initialize(val)
		self.val=val
	end
	def add(ano)
		return GF2Poly.new(self.val^ano.val)
	end
	def +(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		return GF2Poly.new(self.val^ano.val)
	end
	def mul(ano)
		return GF2Poly.new(multiply(self.val,ano.val))
	end
	def *(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		return GF2Poly.new(multiply(self.val,ano.val))
	end
	def div(ano)
		res=divide(self.val,ano.val)
		return [GF2Poly.new(res[0]),GF2Poly.new(res[1])]
	end
	def /(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		res=divide(self.val,ano.val)
		return [GF2Poly.new(res[0]),GF2Poly.new(res[1])]
	end
	def pow(n)
		return GF2Poly.new(power(self.val,n))
	end
	def **(n)
		return GF2Poly.new(power(self.val,n))
	end
	def deg()
		if self.val==0
			return nil
		end
		return log2(self.val).to_i()
	end
	def gcd(ano)
		x=self
		y=ano
		while(y.dim!=nil)
			r=x.div(y)[1]
			x=y
			y=r
		end
		return x
	end
	def exp(mod)
		raise Exception unless mod.instance_of? GF2Poly
		return exponent(self.val,mod.val)
	end
	def prime?()
		return isPrime(self)
	end
	def to_s()
		return format("Poly[%x]",self.val)
	end
	def inspect()
		str=self.class.name+":"
		d=deg()
		if d.nil?
			return str+'0'
		end
		nt=0
		i=d
		while i>=0
			if (((val>>i)&1)!=0)
				if(nt!=0)
					str+='+'
				end
				str+=if i==0 then '1' else 'x^'+i.to_s end
				nt+=1
			end
			i-=1
		end
		return str
	end
	def self.generate_prime(size)
		return get_prime(size)
	end
	def self.x()
		return GF2Poly.new(2)
	end
end

