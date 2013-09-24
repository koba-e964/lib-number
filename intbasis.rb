require 'matrix'

require './field.rb'
require './prime.rb'

def integral_basis(k)
	raise Exception unless k.instance_of?(Field)
	disc=k.disc_gen()
	fctr=factorize(disc)[1] #2æˆÈã‚ÌŽw”‚ðŽ‚Â‘fˆö”‚ð’T‚·
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
		#p^e>=d
		for alpha in basis.to_a
			alpha_p=k.power_mod(alpha,p**e,p*p)
			alpha_p=k.canon(alpha_p)
			puts alpha.inspect+"^#{p**e}(mod #{p}^2)="+alpha_p.inspect
		end
		n=0 #to terminate loop
	end
	nil
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
