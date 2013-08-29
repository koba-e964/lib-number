load './prime.rb'


def lucas_test(n)
	if !mr_prime(n)
		return false
	end
	mod=2**n-1
	s=4
	for i in 1..n-2
		s*=s
		s-=2

		t=s>>n
		s&=mod
		s+=t
		s%=mod

		if s==2
			return false
		end
	end
	s==0
end