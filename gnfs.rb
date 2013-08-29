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

def gnfs_all() #attempts to factorize n=2594177=1049*2473
# m=132 -> n=m^3+17m^2-15m-19
	koer=Field.new([-19,-15,17,1])
	m=132
	gnfs_test0(koer,m,200,200)
end

