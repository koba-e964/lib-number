load './quad.rb'
load './f2mat.rb'


class QFB #factor base
	attr_accessor :us, :ps, :qf 
	def initialize(d)
		self.qf=QF.new(d)
		self.us=[]
		self.ps=[]
	end
	def add(a)
		n=qf.norm(a)
		if n==1 || n==-1
			self.us+=[a]
		else
			if !self.qf.is_prime(a)
				return nil
			end
			self.ps+=[a]
			if a[0]!=0
				self.ps+=[ [a[0],-a[1]] ]
			end
		end
		nil
	end
	def decomp_unit(arg)
		a=arg.clone
		if 1%qf.norm(a)!=0
			return nil
		end
		ary=[0,0]
		if a[0]<0
			ary[0]=1
			a[0]=-a[0]
			a[1]=-a[1]
		end
		sgn=1
		cnt=0
		if a[1]<0
			sgn=-1
			a[1]=-a[1]
		end
		while a!=[1,0]
			a=qf.divide_if(a,self.us[1])
			cnt+=1
			if a[1]<0
				return nil
			end
		end
		ary[1]=sgn*cnt
		return ary
	end
	def factorize(a)
		i=0
		len=self.ps.length
		ary=Array.new(len)
		ary.map!{|v|v=0}
		while i<len
			if qf.divisible(ps[i],a)
				a=qf.divide_if(a,ps[i])
				ary[i]+=1
			else
				i+=1
			end
			
		end
		if 1%qf.norm(a)!=0
			return [nil,a]
		end
		self.decomp_unit(a)+ary
	end
	def size()
		self.ps.length+self.us.length
	end
	def compose(ary)
		ups=self.us+self.ps
		mult=[1,0]
		for i in 0..ary.length-1
			if ary[i]<0
				ups[i]=self.qf.divide_if([1,0],ups[i])
				ary[i]=-ary[i]
			end
			for j in 0..ary[i]-1
				mult=self.qf.mul(mult,ups[i])
			end
			mult
		end
		return mult
	end
	def compose_mod(ary,mod)
		ups=self.us+self.ps
		mult=[1,0]
		for i in 0..ary.length-1
			if ary[i]<0
				ups[i]=self.qf.divide_if([1,0],ups[i])
				ary[i]=-ary[i]
			end
			for j in 0..ary[i]-1
				mult=self.qf.mul(mult,ups[i])
				mult[0]%=mod
				mult[1]%=mod
			end
		end
		return mult
	end
end

def get_qfb2(num=41)
	qfb=QFB.new(2)
	qfb.add [-1,0]
	qfb.add [1,1]
	qfb.add [0,1]
	for i in 3..num
		if (i%8==1||i%8==7)&& mr_prime(i)
			res0=qfb.qf.prime_decomp(qfb,i)
			if res0==nil || res0.length!=2
				puts "i=#{i}, res0=#{res0}"
				next
			end
			qfb.add(res0)
		end
	end
	return qfb
	qfb.add [0,1]
	qfb.add [3,1]
	qfb.add [5,2]
	qfb.add [5,1]
	qfb.add [7,3]
	qfb.add [7,2]
	return qfb
end

class RFB
	attr_accessor :ps
	def initialize()
		self.ps=[]
	end
	def add(p)
		if mr_prime(p)
			self.ps+=[p]
		end
		nil
	end
	def factorize(n)
		i=0
		len=self.ps.length
		ary=Array.new(len).map{|v|v=0}
		while i<len
			if n%self.ps[i]==0
				ary[i]+=1
				n/=self.ps[i]
			else
				i+=1
			end
		end
		if n!=1
			return nil
		end
		ary
	end
	def compose(ary)
		mult=1
		for i in 0..ary.length-1
			mult*=self.ps[i]**ary[i]
		end
		return mult
	end
	def size()
		self.ps.length
	end
	def compose_mod(ary, mod)
		mult=1
		for i in 0..ary.length-1
			mult*=modPower self.ps[i],ary[i],mod
			mult%=mod
		end
		return mult%mod
	end
	def size()
		self.ps.length
	end
end


def get_rfb(max=23)
	rfb=RFB.new
	for i in 2..max
		rfb.add(i)
	end
	return rfb
end

def snfs_test0(m=64,r=18,bmax=6)
	qfb2=get_qfb2((m**(0.4+100.0/m)).to_i)
	rfb=get_rfb((m**0.4).to_i)
	ary=[]
	cnt=0
	puts "Sieving... (a:#{-r..r}, b:1..#{bmax})"
	for b in 1..bmax
		puts "b=#{b}"
		for i in  -r..r
			if b>=2 && gcd(b,i)!=1
				next
			end
			resr=rfb.factorize b*m+i
			resq=qfb2.factorize [i,b]
			if (resr!=nil)&& (resq!=nil && resq[0]!=nil)
				cnt+=1
				ary+=[[i,resr,resq]]
			end
		end
	end
	[rfb,qfb2,ary]
end

def prime_max(m)
	s=(m**0.67).to_i
	if s<97
		s=97
	end
	return [s,s]
end

def snfs_test0_var(m,r,bmax)
	rmax,qmax=prime_max(m)
	qfb2=get_qfb2(qmax)
	rfb=get_rfb(rmax)
	goal=rfb.size+qfb2.size+1
	puts "|rfb|=#{rfb.size}, |qfb2|=#{qfb2.size}"
	puts "The number of pairs needed: #{goal}"
	ary=[]
	cnt=0
	puts "Sieving... (a:#{-r..r}, b:1..#{bmax})"
	for b in 1..bmax
		puts "b=#{b}, cnt=#{cnt}"
		if cnt>=goal
			break
		end
		for i in  -r..r
			if b>=2 && gcd(b,i)!=1
				next
			end
			resr=rfb.factorize b*m+i
			resq=qfb2.factorize [i,b]
			if (resr!=nil)&& (resq!=nil && resq[0]!=nil)
				cnt+=1
				ary+=[[i,resr,resq]]
			end
		end
	end
	[rfb,qfb2,ary]
end

def snfs_test1(m=64,r=18,bmax=6)# to a matrix whose elements are in GF(2)
	rfb,qfb2,res=snfs_test0 m,r,bmax
	if res.size<= rfb.size+qfb2.size
		return nil
	end
	mat=[]
	for re in res
		mat+=[(re[1]+re[2]).map{|v|v%2}]
	end
	[res.map{|re|re[0]},mat]
end

def snfs_test1_only(res)
	mat=[]
	for re in res
		mat+=[(re[1]+re[2]).map{|v|v%2}]
	end
	mat
end


def snfs_test2(m=64,r=18,bmax=6)
	res,mat=snfs_test1 m,r,bmax
	gauss_elim(GF2Mat.new(mat))
end

def snfs_test2_only(mat)
	gauss_elim(GF2Mat.new(mat))
end


def snfs_test3(m=64,r=18,bmax=6)
	n=m*m-2
	time0=Time.now
	rfb,qfb2,orig=snfs_test0_var m,r,bmax
	time1=Time.now
	if orig.length<= rfb.size+qfb2.size
		puts "|orig|=#{orig.length}<=|rfb|(#{rfb.size})+|qfb2|(#{qfb2.size})"
		return nil
	end
	puts "|orig|=#{orig.length}>|rfb|(#{rfb.size})+|qfb2|(#{qfb2.size})"

	answer=[]
	puts "Sieving: #{time1-time0}sec"
	puts "Gauss Elimination..."
	reg,mat=snfs_test2_only(snfs_test1_only(orig))
	time2=Time.now
	puts "Finished!(1)"
	puts "Gauss Elim: #{time2-time1}sec"
	all0=Array.new(mat.n).map{|v|0}
	for i in 0..mat.m-1
		if mat.ary[i]==all0
			answer+=[reg.ary[i]]
		end
	end
	gcds=[]
	cnt=0
	puts "The number of answers: #{answer.length}"
	for ans in answer
		puts "Case:#{cnt}/#{answer.length}"
		cnt+=1
		sum=Array.new(mat.m).map{|v|0}
		for i in 0..ans.length-1
			if ans[i]==0
				next
			end
			result=orig[i][1]+orig[i][2]
			for j in 0..result.length-1
				sum[j]+=result[j]
			end
		end
		sum.map!{|v|v/=2}
		r_prod=rfb.compose_mod(sum[0..rfb.size-1],n)
		q_prod=qfb2.compose_mod(sum[rfb.size..sum.length-1],n)
		q_prod_int=q_prod[0]+q_prod[1]*m
		#puts "r_prod=#{r_prod}, q_prod=#{q_prod}, q_prod_int=#{q_prod_int}"
		g=gcd(n,r_prod+q_prod_int)
		if gcds.index(g)!=nil
			next
		end
		gcds+=[g]
		y=n/g
		if rfb.factorize(g)==nil && rfb.factorize(y)==nil #if non-trivial
			#puts "gcd(n,r_prod+q_prod_int)=gcd(#{n},#{r_prod+q_prod_int})=#{g}"
			puts "#{n}=#{g}*#{y}"
		end
	end
	time3=Time.now
	puts "Compose & gcd: #{time3-time2}sec"
	puts ""
	puts "Results:"
	for g in gcds
		puts "#{n}=#{g}*#{n/g}"
	end
	puts "Sieving: #{time1-time0}sec"
	puts "Gauss Elim: #{time2-time1}sec"
	puts "Compose & gcd: #{time3-time2}sec"
	nil
end
def snfs(a,n,b) #a^n+b
	
end



