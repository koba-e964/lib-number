#curve: [p,a,b]
require_relative "./prime.rb"
require_relative "./gcd.rb"



def invmod(a, p)
  g, i = ext_gcd(a, p)
  if g != 1
    raise StandardError.new("#{g} | #{p}")
  end
  return i
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
	#if !mr_prime(p)
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
			grad=divmod(3*p1[0]*p1[0] + a,2*p1[1],p)
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

def toPro(point)
	point+[1]
end

def npEqual(curve,nP,pP)
	p=curve[0]
	return (nP[0]*pP[2]-pP[0])%p==0 && (nP[1]*pP[2]-pP[1])%p==0
end
def proEqual(curve,p0,p1)
	p=curve[0]
	return (p0[0]*p1[2]-p0[2]*p1[0])%p==0 && (p0[1]*p1[2]-p0[2]*p1[1])%p==0 
end
def proDouble(curve,point)
	p=curve[0]
	a=curve[1]
	mu=(2*point[1]*point[2])%p
	lambda=(3*point[0]*point[0]+a*point[2]*point[2])%p
	gamma=(point[1]*mu)%p
	alpha=(2*point[0]*gamma)%p
	beta=(lambda*lambda-2*alpha)%p
	x3=(mu*beta)%p
	y3=(-lambda*(beta-alpha)-2*gamma*gamma)%p
	z3=(((mu*mu)%p)*mu)%p
	return [x3,y3,z3]
end

def proAdd(curve,p0,p1)
	p=curve[0]
	if p0[2]%p==0
		return p1
	elsif p1[2]%p==0	
		return p0
	elsif proEqual(curve,p0,p1)
		return proDouble(curve,p0)
	end
		
	beta=p0[0]*p1[2]
	beta%=p
	gamma=p0[2]*p1[0]
	gamma%=p
	delta=p0[1]*p1[2]
	delta%=p
	eps=p0[2]*p1[1]
	eps%=p
	lambda=(eps-delta)%p
	mu=(gamma-beta)%p
	pi2=mu*mu
	pi2%=p
	pibeta=beta*pi2
	pibeta%=p
	pigamma=gamma*pi2
	pigamma%=p
	pi3=-pibeta+pigamma
	pi3%=p
	zeta=p0[2]*p1[2]	
	zeta%=p
	alpha=(zeta*lambda*lambda-pibeta-pigamma)%p
	x3=mu*alpha
	y3=lambda*(pibeta-alpha)-pi3*delta
	z3=pi3*zeta
	return [x3%p,y3%p,z3%p]
end

def proMul(curve,point,n)
	sum=[1,1,0]
	if n>0
		cur=point
	elsif n<0
		n=-n
		cur=inv(point)
	else
		return [1,1,0]
	end
	while n>0
		if n%2==1
			sum=proAdd curve,sum,cur
		end
		cur=proDouble curve,cur
		n/=2
	end
	sum
end

def proDoubleChecker()
	for trial in 0..99
		p=getMRPrime 30
		curve=[p,101]
		point=[rand(p) , rand(p)]
		res1=mul(curve,point,2)
		res2=proDouble(curve,toPro(point))
		if !npEqual(curve,res1,res2)
			puts "not equal@proDoubleChecker, #{point}*2,#{res1}!=#{res2}"
		end
	end
end

def proMulChecker()
	for trial in 0..99
		p=getMRPrime 30
		curve=[p,101]
		point=[rand(p) , rand(p)]
		num=rand(p)
		res1=mul(curve,point,num)
		res2=proMul(curve,toPro(point),num)
		if !npEqual(curve,res1,res2)
			puts "not equal@proDoubleChecker, #{point}*2,#{res1}!=#{res2}"
		end
	end
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
				if mr_prime(n_0+i)
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

def getPrimePointType0(curve,debug=true) #searches for a point of order p
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
		if i!=x && mr_prime(cur)
			ary+=[cur]
		end
		cur+=1
	end
	return ary
end

def getPrimePointType1(curve,tnum=100,debug=true)
	p=curve[0]
	x=(3*(log p)).to_i
	ary=[]
	while ary.length==0
		ary=getNearPrime(p,x)
		x*=2
	end
	if debug
		for k in ary
			puts "prime:#{k}"
		end
	end
	for trial in 1..tnum
		init=[rand(p) , rand(p) , 1]
		cur=init
		pwr=1
		for val in ary
			cur=proAdd(curve,cur,proMul(curve,init,val-pwr))
			pwr=val
			if cur[2]==0
				#found!!!
				if debug
					puts "Trial #{trial},obtained a point #{init},p=#{p},period=#{pwr}"
				end
				return [trial,init]
			end
		end
		if debug && trial%500==0
			puts "Trial #{trial} failed."
		end
	end
	nil
end

def testType1()
	for i in 10..25
		sum=0
		for j in 1..100
			curve=[getRandomPrime(i),20]
			trial=0
			while 1
				num=10000
				res=getPrimePointType1(curve,num,false)
				if res!=nil
					trial+=res[0]
					break
				end
				trial+=num
			end
			sum+=trial
		end
		puts "p=#{curve[0]},trial=#{sum/100.0}"
	end
end
