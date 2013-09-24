# -*- coding: cp932 -*-
load './prime.rb'
load './reci.rb'
require './alg-lin.rb'

$debug_field=false

def poly_apply(poly,num)
	val=0
	cur=1
	for coeff in poly
		val+=coeff*cur
		cur*=num
	end
	val
end
def poly_fapply(poly,a,b) #c_0+...c_nx^n-> c_0a^n+c_1a^{n-1}b+...c_nb^n
	if a==0
		return b**(poly.length-1)
	end
	val=0
	cura=a**(poly.length-1)
	curb=1
	for coeff in poly
		val+=coeff*cura*curb
		cura/=a
		curb*=b
	end
	val
end

def poly_degree(poly)
	maxnz=-1
	for i in 0..poly.length-1
		if poly[i]!=0
			maxnz=i
		end
	end
	if maxnz!=-1
		return maxnz
	else
		return nil
	end
end

def poly_div(pa,pb) #pa=pb*res[0]+res[1],in field
	result=[]
	pa=pa.clone
	degb=poly_degree(pb)
	if degb==nil
		return [[0],pa]
	elsif degb==0
		return [pa.map{|v|v/pb[0]},[0]]
	end
	dega=poly_degree(pa)
	if(dega==nil)
		return [[0],[0]]
	end
	i=dega-degb
	while i>=0
		q=pa[i+degb]/pb[degb]
		result[i]=q
		for j in 0..degb
			pa[i+j]-=q*pb[j]
		end
		i-=1
	end
	return [result,pa[0..degb-1]]
end
def poly_mult(pa,pb)
	dega=poly_degree(pa)
	if dega==nil
		return [0]
	end
	degb=poly_degree(pb)
	if degb==nil
		return [0]
	end
	result=Array.new(dega+degb+1).map!{|v|v=0}
	for i in 0..dega
		for j in 0..degb
			result[i+j]+=pa[i]*pb[j]
		end
	end
	return result
end
def poly_mult_mod(pa,pb,mod)
	dega=poly_degree(pa)
	if dega==nil
		return [0]
	end
	degb=poly_degree(pb)
	if degb==nil
		return [0]
	end
	result=Array.new(dega+degb+1).map!{|v|v=0}
	for i in 0..dega
		for j in 0..degb
			result[i+j]+=pa[i]*pb[j]
			result[i+j]%=mod
		end
	end
	return result
end
def poly_add(pa,pb)
	result=Array.new(if pa.length>pb.length then pa.length else pb.length end)
	min=if pa.length<pb.length then pa.length else pb.length end
	for i in 0..min-1
		result[i]=pa[i]+pb[i]
	end
	for k in min..pa.length-1
		result[k]=pa[k]
	end
	for k in min..pb.length-1
		result[k]=pb[k]
	end
	return result
end
def poly_mod(p,mod)
	return p.map{|v|v%mod}
end

#ideal: [p,[a,b]]の形をしている(p,a+b*theta)
#alg num:[a_0, a_1, ...]の形をしている(a_0+a_1*theta+...)


class Field
	attr_accessor :f #minimum polynomial
	def initialize(f) #f must be monic
		self.f=f
	end
	def dim()
		f.length-1
	end
	def norm(eta) #eta=a+b*theta
		a,b=eta
		poly_fapply(self.f,-b,a)
	end
	def get_ideals_on(p) #[p, eta1,eta2,eta3,...]
		ary=[p]
		for s in 0..p-1
			if poly_apply(self.f,s)%p==0
				ary+=[[p-s,1]]
			end
		end
		return ary
	end
	def incl(ideal,eta) #ideal: [p,[a,b]], eta:[a,b,c,...]
		rat=poly_fapply(eta,-ideal[1][1],ideal[1][0])	
		rat%ideal[0]==0
	end
	def quad_res(ideal,eta) #ideal: [p,[a,b]], eta:[a,b,c,...]
		rat=poly_fapply(eta,ideal[1][1],-ideal[1][0])*(ideal[1][1]**(eta.length-1))
		return quad_res_rat(rat,ideal[0])
	end
	def add(alpha,beta)
		return poly_add(alpha,beta)
	end
	def add_mod(alpha,bet,mod)
		return poly_add_mod(alpha,beta,mod)
	end
	def mod(alpha,mod)
		return poly_mod(alpha,mod)
	end
	def mult(alpha,beta)
		poly_div(poly_mult(alpha,beta),self.f)[1]
	end
	def mult_mod(alpha,beta,mod)
		poly_div(poly_mult_mod(alpha,beta,mod),self.f)[1]
	end
	def power(alpha,n)
		if n<=0
			return [1]
		end
		sum=[1]
		cur=alpha
		while n>0
			if n%2!=0
				sum=self.mult(cur,sum)
			end
			cur=self.mult(cur,cur)
			n/=2
		end
		return sum
	end
	def power_mod(alpha,n,mod)
		if n<=0
			return [1]
		end
		sum=[1]
		cur=alpha
		while n>0
			if n%2!=0
				sum=self.mult_mod(cur,sum,mod)
			end
			cur=self.mult_mod(cur,cur,mod)
			n/=2
		end
		return sum
	end
	def eq(alpha,beta)
		dega=poly_degree(alpha)
		if(dega==nil);dega=-1;end
		degb=poly_degree(beta)
		if(degb==nil);degb=-1;end
		if(dega!=degb);return false;end
		return alpha[0..dega]==beta[0..degb]
	end
	def canon(alpha) #basis: 1,theta,...,theta^(dim-1)
		rem=poly_div(alpha,self.f)[1]
		while(rem.size<dim())
			rem<<0
		end
		return rem
	end
	#discriminant of k's generator(theta)
	def disc_gen()
		return disc_gen_field(self)
	end
end

class AFB
	attr_accessor :ary, :qr, :koer
	def initialize(koer)
		self.ary=[] #[[2,eta1,eta2,],[3,pi,nu,zeta, ...],... ]
		self.qr=[]
		self.koer=koer
	end
	def add_p(p,ensure_uniq=false)
		if !mr_prime(p)
			return 0
		end
		if !ensure_uniq
			for i in 0..self.ary.length-1
				if self.ary[i][0]==p
					self.ary.delete_at(i)
					break
				end
			end
		end
		res=koer.get_ideals_on(p)
		if res.length>=2
			self.ary+=[res]
		end
		res.length-1
	end
	def add_qr(p,ensure_unique=false) #add quadratic-residue modulo p.
		if !mr_prime(p)
			return 0
		end
		if !ensure_unique
			for i in 0..self.ary.length-1
				if self.ary[i][0]==p
					return 0
				end
			end
			for i in 0..self.qr.length-1
				if self.qr[i][0]==p
					self.qr.delete_at(i)
					break
				end
			end
		end
		res=koer.get_ideals_on(p)
		if res.length>=2
			self.qr+=[res]
		end
		res.length-1
	end
	def factorize(eta)
		norm=koer.norm(eta)
		if norm==0
			return [nil]
		end
		result=Array.new(self.ary.length)
		for i in 0..self.ary.length-1
			p=self.ary[i][0]
			if norm%p!=0
				result[i]=[0,nil]
				next
			end
			cnt=0
			while norm%p==0
				norm/=p
				cnt+=1
			end
			id_incl=Array.new(self.ary[i].length-1)
			for j in 1..self.ary[i].length-1
				id_incl[j-1]=self.koer.incl([p,self.ary[i][j]],eta)
			end
			result[i]=[cnt,id_incl]
		end
		return result
	end
	def fctr_stop_err(eta)
		norm=koer.norm(eta)
		if norm==0
			return []
		end
		result=[]
		for i in 0..self.ary.length-1
			p=self.ary[i][0]
			if norm%p!=0
				result+=Array.new(self.ary[i].length-1).map{|v|0}
				next
			end
			cnt=0
			while norm%p==0
				norm/=p
				cnt+=1
			end
			id_incl=Array.new(self.ary[i].length-1)
			inclcnt=cnt
			for j in 1..self.ary[i].length-1
				id_incl[j-1]=if self.koer.incl([p,self.ary[i][j]],eta) then 1 else 0 end
				inclcnt-=id_incl[j-1]
			end
			if inclcnt!=0
				if inclcnt==cnt-1
					ind=id_incl.index(1)
					id_incl[ind]=cnt
				else
					return nil
				end
			end
			result+=id_incl
		end
		if 1%norm!=0
			return nil
		end
		return result
	end
	def size()
		sum=0
		for dat in self.ary
			sum+=dat.length-1
		end
		for dat in self.qr
			sum+=dat.length-1
		end
		return sum
	end
	def quad_check(eta) # 1->0, -1->1
		ret=[]
		for j in 0..self.qr.length-1
			pdat=self.qr[j]
			elem=Array.new(pdat.length-1)
			for i in 1..pdat.length-1
				ideal=[pdat[0],pdat[i]]
				res=self.koer.quad_res(ideal,eta)
				elem[i-1]=if res==1 then 0 else 1 end
			end
			ret+=elem
		end
		return ret
	end
	def compose(pat,orig)
		a_prod=[1]
		if orig.length != pat.length
			p "Error(compose_mod@AFB):|orig|(#{orig.length})!=|pat|(#{pat.length})"
			return nil
		end
		for i in 0..orig.length-1
			if pat[i]!=0
				a_prod=self.koer.mult(a_prod,orig[i][0])
			end
		end
		return a_prod
	end
	def compose_mod(pat,orig,mod)
		a_prod=[1]
		if orig.length != pat.length
			p "Error(compose_mod@AFB):|orig|(#{orig.length})!=|pat|(#{pat.length})"
			return nil
		end
		for i in 0..orig.length-1
			if pat[i]!=0
				a_prod=self.koer.mult_mod(a_prod,orig[i][0],mod)
			end
		end
		return a_prod
	end
end
