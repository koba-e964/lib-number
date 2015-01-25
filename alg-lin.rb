require_relative 'matrix'
require_relative 'field.rb'
require_relative './gcd.rb'

def alg_as_matrix_gen(k) #basis:1,theta,...,theta^(d-1)
	f=k.f
	d=k.dim
	ary=Array.new(d){|v|Array.new(d,0)}
	for i in 0..d-2
		ary[i][i+1]=1
	end
	denom=f[d]
	raise Exception unless denom!=0
	for j in 0..d-1
		ary[d-1][j]=Rational(-f[j],denom)
	end
	return Matrix.rows(ary)
end

def alg_as_matrix(k,alpha)
	raise Exception unless k.instance_of?(Field)
	raise Exception unless alpha.instance_of?(Array)
	alpha=k.canon(alpha)
	d=k.dim
	m=Matrix.zero(d)
	g=alg_as_matrix_gen(k)
	c=Matrix.I(d)
	for i in 0...alpha.size
		m+=alpha[i]*c
		c*=g
	end
	return m
end

#discriminant of theta(k=Q(theta))
def disc_gen_field(k)
	raise Exception unless k.instance_of?(Field)
	f=k.f
	d=k.dim
	df=Array.new(d,0)
	for i in 0...d
		df[i]=(i+1)*f[i+1]
	end
	normdif=alg_as_matrix(k,df).det
	if d%4==2||d%4==3
		normdif*=-1
	end
	return normdif.to_i
end

#mat‚Ì•ª•ê‚ð‚­‚­‚è‚¾‚µAintmat/denom‚ÌŒ`‚É‚·‚é(intmat‚Í®ŒW”s—ñ)
# return [denom,intmat] (denom>0)
def denom_out(mat)
	denom=1
	mat.each{|v|
		if v.instance_of?(Rational)
			q=v.denominator.abs
			denom*=q/gcd(q,denom)
		end}
	a=mat.to_a
	for v in a
		for i in 0...v.size
			v[i]*=denom
			v[i]=v[i].to_i
		end
	end
	return [denom,Matrix.rows(a)]
end
