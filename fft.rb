def fft_array_sub(ary, k, start, interval, len, output, ostart, n)
  if len == 1
    output[ostart] = ary[start]
    return nil
  end
  mod = (1 << n) + 1
  fft_array_sub(ary, 2 * k, start, interval * 2, len / 2, output, ostart, n)
  fft_array_sub(ary, 2 * k, start + interval, interval * 2, len / 2, output, ostart + len / 2, n)
  for i in 0 ... (len / 2)
    shift = (i * k) % (2 * n)
    t0 = output[ostart + i] % ((1 << n) + 1)
    t1 = (output[ostart + i + len / 2] << shift) % ((1 << n) + 1)
    tmp0 = t0 + t1
    tmp1 = t0 - t1
    tmp0 %= (1 << n) + 1
    tmp1 %= (1 << n) + 1
    output[ostart + i] = tmp0
    output[ostart + i + len / 2] = tmp1
  end
  return nil
end

def ifft_array_sub(ary, k, start, interval, len, output, ostart, n)
  if len == 1
    output[ostart] = ary[start]
    return nil
  end
  mod = (1 << n) + 1
  ifft_array_sub(ary, 2 * k, start, interval * 2, len / 2, output, ostart, n)
  ifft_array_sub(ary, 2 * k, start + interval, interval * 2, len / 2, output, ostart + len / 2, n)
  for i in 0 ... (len / 2)
    shift = (i * (2 * n - k)) % (2 * n)
    t0 = output[ostart + i] % ((1 << n) + 1)
    t1 = (output[ostart + i + len / 2] << shift) % ((1 << n) + 1)
    tmp0 = t0 + t1
    tmp1 = t0 - t1
    tmp0 %= (1 << n) + 1
    tmp1 %= (1 << n) + 1
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
# Computes ary[0] + ary[1] * 2^(-ik) * ... * ary[size-1] * 2^(-(size-1)*i*k) mod 2^n + 1
def ifft_array(ary, k, n)
  size = ary.size
  if (size & (-size)) != size
    raise Exception.new("ary.size = #{size} is not a power of 2")
  end
  output = Array.new(size)
  ifft_array_sub(ary, k, 0, 1, size, output, 0, n)
  return output
end


def cyclic_convolution(ary1, ary2, k, n)
  tary1 = fft_array(ary1, k, n)
  tary2 = fft_array(ary2, k, n)
  mod = (1 << n) + 1
  t = (Math.log2(ary1.size()) + 0.5).to_i() # ary.size == 1 << t)
  tary3 = (0...ary1.size()).map{|i| (tary1[i] * tary2[i]) % mod}
  cyc = ifft_array(tary3, k, n)
  shift = (- t) % (2 * n)
  return cyc.map{|v| (v << shift) % mod}
end
