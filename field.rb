load './prime.rb'
load './reci.rb'

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

#ideal: [p,[a,b]]‚ÌŒ`‚ð‚µ‚Ä‚¢‚é(p,a+b*theta)
#alg num:[a_0, a_1, ...]‚ÌŒ`‚ð‚µ‚Ä‚¢‚é(a_0+a_1*theta+...)


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
		rat=poly_fapply(eta,-ideal[1][1],ideal[1][0])	
		return quad_res_rat(rat,ideal[0])
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
				return nil
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
end
