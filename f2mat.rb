# A matrix with coefficients in GF(2).

class GF2Mat
	attr_accessor :ary, :m, :n
	def mat_create(m,n)
		self.ary=Array.new(m).map{|v|Array.new(n).map{|v|0}}
		self.m=m
		self.n=n
	end

	def initialize(ary)
		if ary.length==0
			return nil
		end
		self.m=ary.length
		self.n=ary[0].length
		self.ary=[]
		for row in ary
			self.ary+=[row]
		end
	end
	def mul(another)
		if self.n!=another.m
			return nil
		end
		ary=Array.new(self.m).map{|v|Array.new(another.n).map{|v|0}}
		for i in 0..self.m-1
			for j in 0..another.n-1
				sum=0
				for k in 0..self.n-1
					sum^=self.ary[i][k]&another.ary[k][j]
				end
				ary[i][j]=sum
			end
		end
		GF2Mat.new(ary)
	end
	def add(another)
		if self.m!=another.m && self.n!=another.n
			return nil
		end
		ary=self.ary.map{|v|v.clone}
		for i in 0..self.m-1
			for j in 0..self.n-1
				ary[i][j]^=another.ary[i][j]
			end
		end
		GF2Mat.new(ary)
	end
end
def mat_create(m,n)
	ary=Array.new(m).map{|v|Array.new(n).map{|v|0}}
	GF2Mat.new(ary)
end
def unity(n)
	m=mat_create(n,n)
	for i in 0..n-1
		m.ary[i][i]=1
	end
	m
end
def mat_p(n,i,j)
	m=unity n
	if i!=j
		m.ary[i][j]=1
		m.ary[i][i]=0
		m.ary[j][j]=0
		m.ary[j][i]=1
	end
	m
end

def mat_q(n,c,i,j)
	m=unity n
	if i!=j
		m.ary[i][j]=c
	end
	m
end

def ary_swap(ary,i,j)
	if i==j
		return nil
	end
	tmp=ary[i]
	ary[i]=ary[j]
	ary[j]=tmp
	nil
end

def gauss_elim(mat) #p*mat=res, [p,res]
	puts "Gauss Elim: (m=#{mat.m},n=#{mat.n})"
	mat2=mat.clone
	mat2.ary=mat.ary.map{|v|v.clone}
	p=unity mat2.m
	r=0
 	interv=mat2.n/10
	for i in 0..mat2.n-1
		if i%interv==0
			puts "processing column #{i}/#{mat.n}\r"
		end
		if r>=mat2.m
			break
		end
		onerow=-1
		for j in r..mat2.m-1
			if mat2.ary[j][i]==1
				onerow=j
				break
			end
		end
		if onerow>=0
			ary_swap(mat2.ary,onerow,r)
			ary_swap(p.ary,onerow,r)
			for k in r+1..mat2.m-1
				if mat2.ary[k][i]==1
					for l in i..mat2.n-1
						mat2.ary[k][l]^=mat2.ary[r][l]
					end
					for l in 0..p.n-1
						p.ary[k][l]^=p.ary[r][l]
					end
				end
			end
			r+=1
		end
	end
	[p,mat2]
end
