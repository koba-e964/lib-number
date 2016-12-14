# coding: cp932
require 'matrix'

require './field.rb'
require './prime_util.rb'

def integral_basis(k)
  raise Exception unless k.instance_of?(Field)
  disc=k.disc_gen()
  fctr=factorize(disc.abs) #2乗以上の指数を持つ素因数を探す
  index=1
  for p,n in fctr
    #get p-maximal order of k.
    puts p_maximal_order(k,p,n).inspect
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
			frob_o << (Matrix.row_vector(alpha_p)*basis.inv).to_a[0].map{|v|v.to_i%p}
		end
		puts frob_o.inspect
		kernel=kernel_mod(frob_o,p)
		i_p=(kernel+(basis*p).to_a)[0...d] #FIXME TODO BUGGY
		i_p=Matrix.rows(i_p) #basis:order
		puts "I_#{p}="+i_p.inspect
		i_p_init=i_p*basis #basis:initial
                prod_ip_mat = Array.new(d){|v| []}
		for i in 0...d
		  for j in 0...d
		    prod_init=k.mult_mod(i_p_init.to_a[i],i_p_init.to_a[j],p*p)
		    prod_init=k.canon(prod_init)
		    prod_ip=Matrix.row_vector(prod_init)*i_p_init.inv
		    puts "e[#{i}]*e[#{j}]=(init)"+prod_init.inspect+", (I_p)="+prod_ip.inspect
                    prod_ip_mat[j] += prod_ip.to_a[0].map{|w| v = w.to_i; raise Exception unless w == v; v }
		  end
		end
                p prod_ip_mat
                ker = kernel_mod(prod_ip_mat, p)
                for i in 0 ... d
                  one_hot = Array.new(d, 0)
                  one_hot[i] = p
                  ker << one_hot
                end
                ker = ker.map{|row_vec| Matrix.row_vector(row_vec) * i_p / Rational(p, 1) }
                puts "kernel(U_#{p}) = #{ker.inspect}"
                basis = ker
                # TODO reduce basis
		n=0 #to terminate loop
                
	end
	basis
end

# computes a basis of {x | x A = 0}, represented by an array of row vectors
# ary:array representing matrix
# mod:prime
def kernel_mod(ary, mod, debug = false)
  ary=ary.clone
  ary.map!{|v| v = v.clone } # Gain a deep copy of ary
  n=ary.size
  m = ary[0].size
  unit=Array.new(n).map{|v|Array.new(n,0)}
  for i in 0...n
    unit[i][i]=1
  end
  for i in 0...n
    ary[i].map!{|v|v%mod}
  end
  for i in 0...n
    k=0
    while ary[i][k]==0 && k<m
      k+=1
    end
    if k==m
      break
    end
    invc=ext_gcd(ary[i][k],mod)[1]%mod
    for r in 0...n
      if r==i
	next
      end
      q=-ary[r][k]*invc
      q%=mod
      for j in 0 ... m
	ary[r][j]+=q*ary[i][j]
	ary[r][j]%=mod
      end
      for j in 0 ... n
	unit[r][j]+=q*unit[i][j]
	unit[r][j]%=mod
      end
    end
  end
  if debug
    puts "unit="+unit.inspect+", ary="+ary.inspect
  end
  res=[]
  for i in 0...n
    if (0 ... m).all?{|v| ary[i][v] == 0}
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
