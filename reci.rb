load './prime.rb'

def quad_res_rat(a,p)
	if p%2==0
		if p==2
			r=a%8
			if r%2==0	
				return 0
			elsif r==-1 || r==7
				return 1
			else
				return -1
			end
		else
			return nil
		end
	end
	r=modPower(a,(p-1)/2,p)
	if r==p-1
		return -1
	else
		return r
	end
end
