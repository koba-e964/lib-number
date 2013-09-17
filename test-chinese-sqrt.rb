load './prime.rb'
load './modsqrt.rb'
load 'gcd.rb'



def mod_pow_sqrt(a,p,n) # sqrt(a mod p^n)
	if p==2
		return mod_pow_2_sqrt(a,n)
	end
	res=modsqrt(a,p)
	mod=p
	for i in 1...n
		rem=a-res*res
		if rem%mod!=0;raise Exception;end
		rem/=mod
		inv=ext_gcd(2*res,mod*p)
		if inv[0]!=1;raise Exception;end
		adde=(rem*inv[1])%p
		res+=adde*mod
		mod*=p
	end
	return res
end

def mod_pow_2_sqrt(a,n) # sqrt(a mod 2^n)
	if n==0;return 0;end
	if n==1;return a%2;end
	if a%8!=1 && a%4==0 ; raise Exception;end
	res=1
	mod=4
	n-=1
end
