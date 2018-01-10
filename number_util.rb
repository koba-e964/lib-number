class NumberUtil
  class << self
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

    def is_bth_power(n, b)
      # super tenuki
      raise Exception.new("n >= 2 should hold") unless n >= 2
      raise Exception.new("b >= 2 should hold") unless b >= 2
      lo = -1
      hi = 1 << ((8 * n.size + b - 1) / b)
      while hi - lo > 1
        mid = (hi + lo) / 2
        if mid ** b < n
          lo = mid
        else
          hi = mid
        end
      end
      if hi ** b == n
        hi
      else
        nil
      end
      
    end
    
    # if n >= 2, 
    # it returns [x, b] where n = x^b and b is largest possible
    def check_power(n)
      if n <= 1
        return [n, 1]
      end
      x = n
      b = 1
      c = 2
      while true
        found = false
        while c <= 8 * x.size
          res = NumberUtil::is_bth_power(x, c)
          if res
            x = res
            b *= c
            found = true
            break
          end
          if c >= 3
            c += 2
          else
            c += 1
          end
        end
        if found
          next
        else
          break
        end
      end
      return [x, b]
    end
  end
end
