load './prime.rb'
def general_rho(b,a,p) #log_b(a mod p)
	if !mr_prime(p)
        raise Exception 
    end
    u=p/3
    v=2*p/3
	t0=[1,0,0]
    t1=[1,0,0]
    i=0
    solved=false
    while !solved && i<p
        t0=gr_next(t0,p,u,v,a,b)
        t1=gr_next(t1,p,u,v,a,b)
        t1=gr_next(t1,p,u,v,a,b) #twice
        if(t0[0]==t1[0])
            #debug
            puts "i="+i.to_s
            p t0
            p t1
            m=t0[1]-t1[1]
            n=t1[2]-t0[2]
            mg=gcd(m,p-1)
            if mg==1
                print (n.to_s+'/'+m.to_s+' mod '+(p-1).to_s)
                puts '='+((n*ext_gcd(m,p-1)[1])%(p-1)).to_s
                solved=true
                break
            else
                print(n.to_s+'/'+m.to_s+' mod '+(p-1).to_s)
                res=ext_gcd(m,p-1)
                mod=(p-1)/mg
                puts '='+(n*res[1]%mod).to_s+'+'+mod.to_s+'Z'
            end
        end
        i+=1
    end
    if(!solved)
        puts 'failed to find proper (m,n)'
    end
end

def gr_next(tup,p,u,v,a,b)
	g=tup[0]
    n=p-1
    if(g<u)
        return [(a*g)%p,(tup[1]+1)%n,tup[2]]
    end
    if(g<v)
        return [(g*g)%p,(tup[1]*2)%n,(2*tup[2])%n]
    end
    return [(b*g)%p,tup[1],(tup[2]+1)%n]
end
