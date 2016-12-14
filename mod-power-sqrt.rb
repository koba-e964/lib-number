require_relative './prime_util.rb'
require_relative './modsqrt.rb'
require_relative './gcd.rb'



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
	old_a = a
	a %= 1 << n
	if a == 0; return 0; end
	shift = 0
	while a % 2 == 0
		a /= 2
		shift += 1
	end
	n -= shift
	if shift % 2 != 0; raise Exception.new("2 ^ #{shift} || #{old_a}"); end
	if n == 1;return 1 << (shift / 2) ;end
	if n == 2
		if a == 1
			return 1 << (shift / 2)
		else
			raise Exception
		end
	end
	# n >= 3
	if a%8 != 1 ; raise Exception;end
	res=1
	# calculate res s.t. a = res * res mod (2 ^ n)
	# constant: a = res^2 (mod 2^i)
	for i in 3...n
		rem = a - res * res
		rem >>= i
		res += (rem % 2) << (i - 1)
	end
	return res << (shift / 2)
end

def test_pow2_sqrt(maxt = 20)
	for t in 1 .. maxt
		n = 1000 * t
		st = Time.now
		res = mod_pow_2_sqrt(17, n)
		en = Time.now
		puts "n = #{n}, time: #{en-st}sec"
		if (res * res - 17) % (1 << n) != 0
			raise Exception.new("n = #{n}")
		end
	end		
end

