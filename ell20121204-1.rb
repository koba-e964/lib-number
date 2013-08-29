#curve: [p,a,b]
def invmod(a,p)
	cur=a
	mul=1
	exp=p-2
	while exp>0
		if exp%2==1
			mul*=cur
			mul%=p
		end
		cur*=cur
		cur%=p
		exp/=2
	end
	mul
end

def divmod(a,b,p)
	(a*invmod(b,p))%p
end
def equal(curve,p1,p2)
	p=curve[0]
	(p1[0]-p2[0])%p==0 and (p1[1]-p2[1])%p==0
end

def add(curve,p1,p2)
	p=curve[0]
	#if !isPrime(p)
		#return nil
	#end
	if p1.length==0 #infinity
		return p2
	elsif p2.length==0
		return p1
	end
	grad=0
	a=curve[1]
	if equal curve,p1,p2
		if p1[1]%p==0
			return []
		else
			grad=divmod(3*p1[0]*p1[0] - a,2*p1[1],p)
		end
	else
		if (p1[0]-p2[0])%p==0
			return []
		end
		grad=divmod(p1[1]-p2[1],p1[0]-p2[0],p)
	end
	p3=[0,0]
	p3[0]=grad*grad-p1[0]-p2[0]
	p3[0]%=p
	p3[1]=-p1[1]-grad*(p3[0]-p1[0])
	p3[1]%=p
	return p3
end
def inv(point)
	if point.length==0
		return []
	end
	a=point.clone
	a[1]*=-1
	return a
end
def mul(curve,point,n)
	sum=[]
	if n>0
		p=point
	elsif n<0
		n=-n
		p=inv(point)
	else
		return []
	end
	cur=p
	while n>0
		if n%2==1
			sum=add curve,sum,cur
		end
		cur=add curve,cur,cur
		n/=2
	end
	sum
end

def period(curve,point)
	if point.length==0
		return 1
	end
	num=1
	cur=point
	while cur.length!=0
		cur=add curve,cur,point
		num+=1
	end
	return num
end

def isPrime(num)
	if num<=1
		return false
	elsif num<=3
		return true
	end
	if num%2==0
		return false
	elsif num%3==0
		return false
	end
	div=5
	while div*div<=num
		if num%div==0 and num!=div
			return false
		elsif num%(div+2)==0 and num!=div+2
			return false
		end
		div+=6
	end
	true
end

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

def mrTest(num,cert=20)
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
	val=rand(1<<length)
	val|=1<<(length-1)
	val|=1
	while 1
		if isPrime(val)
			return val
		end
		val+=2
		val%=(1<<length)
		val|=1<<(length-1)
	end
	nil
end
def getMRPrime(length)
	val=(1<<(length-1))|(rand(1<<(length-2))<<1)|1
	while 1
		if mrTest(val,20)
			return val
		end
		val+=2
		val%=(1<<length)
		val|=1<<(length-1)
	end
	nil
end	

include Math
def getPrimePoint(curve)
	p=curve[0]
	sp=(sqrt p).to_i
	n_0=p+1-2*sp
	trial=100
	while trial>0
		init=[rand(p),rand(p)]
		puts "trial:#{100-trial},selection=(#{init[0]},#{init[1]})"
		cur=mul(curve,init,n_0)
		for i in 0..4*sp
			if cur.length==0
				#period=n_0+i
				if isPrime(n_0+i)
					p "Obtained the point:(#{init[0]},#{init[1]}),period=#{n_0+i}"
					return n_0+i
				else
					p "Fail:(#{init[0]},#{init[1]}),period=#{n_0+i} (not a prime)"
				end
				break
			end
			cur=add(curve,cur,init)
		end
		trial-=1
	end
end

def getPrimePointType0(curve,debug=true) #à êîpÇÃì_ÇíTÇ∑
	p=curve[0]
	trial=0
	while trial<10000
		init=[rand(p),rand(p)]
		#puts "trial:#{trial},selection=(#{init[0]},#{init[1]})"
		result=mul(curve,init,p)
		if result.length==0
			#period=p
			if debug
				puts "Trial #{trial},Obtained the point:(#{init[0]},#{init[1]}),period=p=#{p}"
			end
			return [trial,init]
		else
			#puts "Fail:(#{init[0]},#{init[1]}),period!=p"
		end
		trial+=1
	end
	if debug
		puts "Not Found"
	end
	return nil
end

def testType0()
	for i in 10..25
		curve=[getRandomPrime(i),20]
		trial=0
		while 1
			res=getPrimePointType0(curve,false)
			if res!=nil
				trial+=res[0]
				break
			end
			trial+=10000
		end
		puts "p=#{curve[0]},trial=#{trial}"
	end
end

def getNearPrime(p,x)
	ary=[]
	cur=p-x
	for i in 0..2*x
		if mrTest(cur)
			ary+=[cur]
		end
		cur+=1
	end
	return ary
end

