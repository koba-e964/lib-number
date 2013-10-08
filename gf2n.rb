load 'gcd.rb'
module GF2n
	module_function
	include Math
	def isPrimeFast(poly)
		raise Exception unless poly.is_a?GF2Poly
		if(poly==0||poly==1)
			return false
		end
		deg=poly.deg()
		if deg==1
			return true #poly=x or x+1
		end
		x=GF2Poly::x
		for r in 1..deg/2 #r>=1
			q=x.pow_mod(1<<r,poly)
			q+=x
			gcd=poly.gcd(q)
			if gcd!=1
				return false
			end
		end
		return true
	end
	def isPrimeFast2(poly)
		raise Exception unless poly.is_a?GF2Poly
		if(poly==0||poly==1)
			return false
		end
		deg=poly.deg()
		if deg==1
			return true #poly=x or x+1
		end
		x=GF2Poly::x
		lcm=1
		for r in 1..deg/2 #r>=1
			nt=(1<<r)-1
			lcm*=nt/gcd(nt,lcm)
		end
		sum=x.pow_mod(lcm,poly)
		sum+=1
		sum*=x
		gcd=poly.gcd(sum)
		return gcd==1
	end
	def test_isPrime()
		trial=0
		err=0
		while trial<100
			v=rand(1<<100)
			po=GF2Poly.new(v)
			t1=Time.now
			r1=isPrimeFast(po)
			t2=Time.now
			r2=isPrimeFast2(po)
			t3=Time.now
			if(r1!=r2)
				p [po,r1,r2]
			end
			p [t2-t1,t3-t2]
			trial+=1
		end
		puts err.to_s+'/'+trial.to_s
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
		if(deg==1)
			return 2
		end
		c=0
		i=(1<<(deg))+1
		while i<(1<<(deg+1))
			if GF2Poly.new(i).prime?
				c+=1
			end
			i+=2
		end
		return c
	end
end #module GF2n

class GF2Poly
	include GF2n
	include Math
	extend GF2n
	attr_accessor :val
	def initialize(val)
		if val<0
			raise 'val=-0x'+(-val).to_s(16)+'<0, which is invalid'
		end
		self.val=val
	end
	def add(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		return GF2Poly.new(self.val^ano.val)
	end
	def +(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		return GF2Poly.new(self.val^ano.val)
	end
	def mul(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		a=self.val
		b=ano.val
		sum=0
		while b>0
			if(b%2==1)
				sum^=a
			end
			b/=2
			a*=2
		end
		GF2Poly.new(sum)
	end
	def *(ano)
		mul(ano)
	end
	def div(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		a=self.val
		b=ano.val
		q=0
		sb=log2(b).to_i()
		th=1<<sb
		while(a>=th)
			sa=log2(a).to_i()
			a^=b<<(sa-sb)
			q^=1<<(sa-sb)
		end
		return [GF2Poly.new(q),GF2Poly.new(a)] #quotient,remainder
	end
	def /(ano)
		return div(ano)[0]
	end
	def %(ano)
		return div(ano)[1]
	end
	def pow(n)
		if(n<0)
			raise
		end
		s=GF2Poly.new(1)
		c=self
		while(n>0)
			if(n%2==1)
				s*=c
			end
			c*=c
			n/=2
		end
		return s
	end
	def pow_mod(n,mod)
		if mod.is_a?Integer
			mod=GF2Poly.new(mod%2)
		end
		if(n<0)
			raise
		end
		s=GF2Poly.new(1)
		c=self
		while(n>0)
			if(n%2==1)
				s*=c
				s%=mod
			end
			c*=c
			c%=mod
			n/=2
		end
		return s
	end
	def **(n)
		pow(n)
	end
	def ==(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		return val==ano.val
	end
	def deg()
		if self.val==0
			return nil
		end
		return log2(self.val).to_i()
	end
	def gcd(ano)
		if(ano.is_a?Integer)
			ano=GF2Poly.new(ano%2)
		end
		x=self
		y=ano
		while(y!=0)
			r=x%y
			x=y
			y=r
		end
		return x
	end
	def exp(mod)
		raise Exception unless mod.instance_of? GF2Poly
		sm=mod.deg
		s=self
		cnt=1
		while(s!=1 && cnt<(1<<sm))
			s*=a
			s%=mod
			cnt+=1
		end
		if(cnt>=(1<<sm))
			raise Exception("Error:too large exponent")
		end
		return cnt
	end
	def prime?()
		return isPrimeFast(self)
	end
	def to_s()
		return format("Poly[%x]",self.val)
	end
	def inspect()
		str=self.class.name+":"
		if self==0
			return str+'0'
		end
		d=deg()
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
	def self.generate_minimal_prime(size)
		raise 'size<=0' if(size<=0)
		v=1<<size
		while(v<1<<(size+1))
			po=GF2Poly.new(v)
			if(po.prime?)
				return po
			end
			v+=1
		end
		raise 'error'
	end
	def self.x()
		return GF2Poly.new(2)
	end
end

