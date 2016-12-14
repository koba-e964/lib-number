# returns the smallest i s.t. n < 2^i
def bit_size(n)
  size = n.size * 8
  while true
    if n[size] != 0
      return size + 1
    end
    size -= 1
  end
  raise Exception.new("unreachable")
end

# a mod 2^n if 0 <= a < 2^2n
def reduce_2n1(a, n)
  b = a >> n
  a = a & ((1 << n) - 1)
  r = a - b
  if r < 0
    return r + (1 << n) + 1
  end
  return r
end


def fft_array_sub(ary, k, start, interval, len, output, ostart, n)
  if len == 1
    output[ostart] = ary[start]
    return nil
  end
  mod = (1 << n) + 1
  newk = (2 * k) % (2 * n)
  fft_array_sub(ary, newk, start, interval * 2, len / 2, output, ostart, n)
  fft_array_sub(ary, newk, start + interval, interval * 2, len / 2, output, ostart + len / 2, n)
  for i in 0 ... (len / 2)
    shift = (i * k) % (2 * n)
    t0 = output[ostart + i]
    t1 = output[ostart + i + len / 2] << shift
    tmp0 = t0 + t1
    tmp1 = t0 - t1 + (1 << n) + 1
    tmp0 = reduce_2n1(tmp0, n)
    tmp1 = reduce_2n1(tmp1, n)
    output[ostart + i] = tmp0
    output[ostart + i + len / 2] = tmp1
  end
  return nil
end



# Computes ary[0] + ary[1] * 2^ik * ... * ary[size-1] * 2^((size-1)*i*k) mod 2^n + 1
def fft_array(ary, k, n)
  size = ary.size
  if (size & (-size)) != size
    raise Exception.new("ary.size = #{size} is not power of 2")
  end
  output = Array.new(size)
  fft_array_sub(ary, k, 0, 1, size, output, 0, n)
  return output
end

# cyclic convolution modulo 2^n+1
# n % ary.size == 0
def cyclic_convolution(ary1, ary2, n)
  t = bit_size(ary1.size()) - 1 # ary.size == 1 << t
  if ary1.size() != 1 << t || ary2.size() != 1 << t
    raise Exception.new("array size error")
  end
  if (n & ((1 << (t-1)) - 1)) != 0
    raise Exception.new "2n = #{2 * n} is not divisible by ary1.size() = #{1 << t}"
  end
  # if ary1.size = ary2.size = 2^t, (2^k) ^ (2^(t-1)) = -1 (mod 2^n+1)
  k = n >> (t - 1)
  tary1 = fft_array(ary1, k, n)
  tary2 = fft_array(ary2, k, n)
  mod = (1 << n) + 1
  tary3 = (0...ary1.size()).map{|i| (tary1[i] * tary2[i]) % mod}
  cyc = fft_array(tary3, 2 * n - k, n)
  shift = (- t) % (2 * n)
  return cyc.map{|v| (v << shift) % mod}
end

def schoenhage_strassen(a, b)
  large_n = bit_size(a) + bit_size(b)
  k = (bit_size(large_n) + 1) / 2
  width = ((large_n - 1) >> k) + 1
  ary_a = (0 ... 1 << k).map{|i| (a >> (width * i)) & ((1 << width) - 1)}
  ary_b = (0 ... 1 << k).map{|i| (b >> (width * i)) & ((1 << width) - 1)}
  n = ((2 * width + k) & ((-1) << k)) + (1 << k)
  result = cyclic_convolution(ary_a, ary_b, n)
  acc = 0
  i = (1 << k) - 1
  while i >= 0
    acc <<= width
    acc += result[i]
    i -= 1
  end
  return acc
end
