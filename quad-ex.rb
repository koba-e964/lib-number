load './prime.rb'
load './quad.rb'

def calc(p)
	sum=0
	for t in 2..(p-1)/2
		sum+=legendre(t,p)*legendre(1-t,p)
	end
	return sum
end