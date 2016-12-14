# coding: cp932
require 'matrix'

require './field.rb'
require './prime.rb'

def integral_basis(k)
	raise Exception unless k.instance_of?(Field)
	disc=k.disc_gen()
	fctr=factorize(disc.abs) #2乗以上の指数を持つ素因数を探す
	index=1
	for p,n in fctr
		#get p-maximal order of k.
		p_maximal_order(k,p,n)
	end
	nil
end

#round 2 method
def p_maximal_order(k,p,n)
	basis=Matrix.I(k.dim())
	d=k.dim
	while n>=2
		#calculate I_p={x in O|x^d in pO} 
		e=0
		while d>=2
			d=(d+p-1)/p
			e+=1
		end
		d=k.dim
		#p^e>=d
		frob_init=[] #basis:initial
		frob_o=[] #basis:order
		for alpha in basis.to_a
			alpha_p=k.power(alpha,p**e)
			alpha_p=k.canon(alpha_p)
			alpha_p_mod=alpha_p.map{|v|v%p}
			puts alpha.inspect+"^#{p**e}(mod #{p})="+alpha_p_mod.inspect
			frob_init << alpha_p_mod
			frob_o<<(Matrix.row_vector(alpha_p)*basis.inv).to_a[0].map{|v|v.to_i%p}
		end
		puts frob_o.inspect
		kernel=kernel_mod(frob_o,p)
		i_p=(kernel+(basis*p).to_a)[0...d] #FIXME TODO BUGGY
		i_p=Matrix.rows(i_p) #basis:order
		puts "I_#{p}="+i_p.inspect
		i_p_init=i_p*basis #basis:initial
		for i in 0...d
			for j in 0...d
				prod_init=k.mult_mod(i_p_init.to_a[i],i_p_init.to_a[j],p*p)
				prod_init=k.canon(prod_init)
				prod_ip=Matrix.row_vector(prod_init)*i_p_init.inv
				puts "e[#{i}]*e[#{j}]=(init)"+prod_init.inspect+", (I_p)"+prod_ip.inspect
			end
		end
		n=0 #to terminate loop
	end
	nil
end

#ary:array representing matrix
#mod:prime
def kernel_mod(ary,mod)
	ary=ary.clone
	n=ary.size
	unit=Array.new(n).map{|v|Array.new(n,0)}
	for i in 0...n
		unit[i][i]=1
	end
	for i in 0...n
		ary[i].map!{|v|v%mod}
	end
	for i in 0...n
		k=0
		while ary[i][k]==0 && k<n
			k+=1
		end
		if k==n
			break
		end
		invc=ext_gcd(ary[i][k],mod)[1]%mod
		for r in 0...n
			if r==i
				next
			end
			q=-ary[r][k]*invc
			q%=mod
			for j in 0...n
				ary[r][j]+=q*ary[i][j]
				ary[r][j]%=mod
				unit[r][j]+=q*unit[i][j]
				unit[r][j]%=mod
			end
		end
	end
	puts "unit="+unit.inspect+", ary="+ary.inspect
	res=[]
	for i in 0...n
		if(ary[i]==Array.new(n,0))
			res << unit[i]
		end
	end
	return res
end

#order, suborder is given by matrice
# Matrix[[a_ij]]_ij means that the basis of order is (sum_{j=0}^{d-1}a_ij*theta^j)(i=0,...,d-1)
def order_index(order,suborder)
	raise Exception unless order.instance_of?(Matrix)
	raise Exception unless suborder.instance_of?(Matrix)
	raise Exception unless order.square? && suborder.square?
	raise Exception unless order.row_size==suborder.row_size
	raise Exception unless order.regular? && suborder.regular?
	d1=order.det
	d2=suborder.det
	raise Exception.new("not a suborder") unless d2%d1==0
	return (d2/d1).abs
end
