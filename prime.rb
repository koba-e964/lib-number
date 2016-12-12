require_relative './gcd.rb'



def modPower(a,b,mod)
	mul=1
	cur=a
	while b>0
		if b%2==1
			mul*=cur
			mul%=mod
		end
		cur*=cur
		cur%=mod
		b/=2
	end
	return mul
end
def mr_prime(num,cert=20)
	if num<=1
		return false
	end
	base=[2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127]
	#base=[2]
	for f in base
		if num==f
			return true
		elsif num%f==0
			return false
		end
	end
	pwr2=0
	quo=num-1
	while quo%2==0
		pwr2+=1
		quo/=2
	end
	#num-1=quo*2**pwr2

	for i in 1..cert
		a=rand(num)
		if a==0
			a=1
		end
		res=modPower(a,quo,num)
		#puts "a=#{a},quo=#{quo},a**quo=#{res}"
		if res==1
			next
		end
		for j in 1..pwr2
			tmp=(res*res)%num #a**(quo*2**j)%num
			if tmp==num-1
				if j<pwr2
					break
				else
					#puts "num={#num},prev=#{res},next=#{tmp},pwr2=#{pwr2},j=#{j}"
					return false
				end
			elsif tmp==1
				if res==num-1
					break
				end
				
				#puts "num=#{num},prev=#{res},next=#{tmp}"
				return false
			end
			if tmp!=1 and j==pwr2
				#puts "a(#{a})**(num-1)(#{num-1})=#{res}"
				return false
			end
			res=tmp
		end
	end
	return true
end

def getRandomPrime(length)
	val=rand(1 << length)
	val|=1<<(length-1)
	val|=1
	while 1
		if mr_prime(val)
			return val
		end
		val+=2
		val%=(1 << length)
		val|=1 << (length-1)
	end
	nil
end

# a<=p<=b
def get_prime_range(a,b)
	if b<a then return nil end
	len=b-a+1
	start=rand(len)
	for i in start..start+len-1
		if mr_prime(a+(i%len))
			return a+(i%len)
		end
	end
	nil #not found
end


include Math

def get_power(num,p)
	cnt=0
	while num%p==0
		num/=p
		cnt+=1
	end
	[num,cnt]
end
def factorize(num)
	if num<0
		return [[-1, 1]] + factorize(-num)
	elsif num==0
		return [[0,1]]
	elsif num==1
		return []
	elsif mr_prime num
		return [[num,1]]
	else
		i=2
		while i*i<=num
			if num%i==0
				tmp=get_power(num,i)
				return [[i,tmp[1]]]+factorize(tmp[0])
			end
			i+=1
		end
		return [[num,1]]
	end
	return nil
end

def gen_test(n,radix=10)
	a=radix**(n-1)
	b=(radix**n)-1
	start=Time.now
	p=get_prime_range(a,b)
	e=Time.now
	puts "time=#{e-start}sec"
	return p
end

def mr_time(n,trial=100)
	st=Time.now
	for i in 1..trial
		p=rand(2**(n-1))+2**(n-1)
		b=mr_prime p,1
	end
	t=Time.now-st
	puts "mr_test trial=#{trial}, time=#{t}sec"
	puts "Average=#{t/trial}sec"
	t/trial
end
def mr_graph(a=100,b=300)
	ary=[]
	for i in a..b
		t=mr_time(i,10000)
		ary+=[[i,t]]
	end
	ary
end
