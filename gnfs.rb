load './field.rb'
load './alg.rb'

def base_exp(n,radix=10)
	ary=[]
	while n>0
		ary=[n%radix]+ary
		n/=radix
	end
	ary
end


def get_afb(field,maxp,nqr=12)
	afb=AFB.new(field)
	for i in 2..maxp
		afb.add_p(i,true)
	end
	cnt=0
	i=maxp+1
	while cnt<nqr
		numbre=afb.add_qr(i)
		cnt+=numbre
		i+=1
	end
	for elem in afb.ary
		p elem
	end
	return afb
end

def gnfs_test0(koer,m,r=10,bmax=100)  
	afb=get_afb(koer,100,20)
	rfb=get_rfb(50)
	goal=rfb.size+afb.size+1
	puts "|rfb|=#{rfb.size}, |afb|=#{afb.size}"
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
			t=b*m+i
			if t<=0
				next
			end
			resr=rfb.factorize t
			if resr==nil
				next
			end
			resa=afb.fctr_stop_err [i,b]
			if resa==nil
				next
			end
			res_qc=afb.quad_check [i,b]
			if res_qc==nil
				next
			end
			cnt+=1
			ary+=[[[i,b],resr,resa,res_qc]]
		end
	end
	[rfb,afb,ary]

end
def gnfs_test1(res)
	mat=[]
	for re in res
		mat+=[(re[1]+re[2]+re[3]).map{|v|v%2}]
	end
	gauss_elim(GF2Mat.new(mat))
end
def gnfs_test2(m,n,rfb,afb,reg,mat,orig)
	all0=Array.new(mat.n).map{|v|0}
	answer=[]
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
		sum=Array.new(rfb.size).map{|v|0}
		for i in 0..ans.length-1
			if ans[i]==0
				next
			end
			result=orig[i][1]
			for j in 0..result.length-1
				sum[j]+=result[j]
			end
		end
		sum.map!{|v|v/=2}
		r_prod=rfb.compose_mod(sum[0..rfb.size-1],n)
		a_prod=afb.compose(ans,orig)
		a_prod_int=poly_apply(a_prod,m)%n
		puts "r_prod=#{r_prod}, a_prod=#{a_prod}, a_prod_int=#{a_prod_int}"
		if true #test
			if (r_prod**2-a_prod_int)%n!=0
				puts "Error! Case #{cnt-1}"
			end
		end
		next
		g=gcd(n,r_prod+a_prod_int)
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
	return gcds
end
def gnfs_all() #attempts to factorize n=2594177=1049*2473
# m=132 -> n=m^3+17m^2-15m-19
	poly=[-19,-15,17,1]
	#poly=[2,0,0,1]
	koer=Field.new(poly)
	m=13200
	#m=11
	n=poly_apply(poly,m);
	rfb,afb,orig=gnfs_test0(koer,m,2000,200)
	if orig.size-rfb.size-afb.size<=0
		puts "Short of combination"
	end
	puts "Gauss Elim..."
	reg,mat=gnfs_test1(orig)
	puts "GE finished!!"
	gnfs_test2(m,n,rfb,afb,reg,mat,orig)
	puts "n=#{n},m=#{m}"
end

