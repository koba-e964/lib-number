require 'matrix'

def elementary_addition(m, t, k, q)
  Matrix.build(m, m) {|i, j|
    if i == j
      1
    elsif i == t && j == k
      q
    else
      0
    end
  }
end

def elementary_switch(m, x, y)
  Matrix.build(m, m) {|i, j|
    if i == x
      j == y ? 1 : 0
    elsif i == y
      j == x ? 1 : 0
    elsif i == j
      1
    else
      0
    end
  }
end

def elementary_multiplication(m, x, v)
  Matrix.build(m, m) {|i, j|
    if i == j
      i == x ? v : 1
    else
      0
    end
  }
end


# https://en.wikipedia.org/wiki/Smith_normal_form#Algorithm
def smith_normal_form(mat)
  n = mat.row_size
  m = mat.column_size
  s_mat = Matrix.unit(n)
  t_mat = Matrix.unit(m)

  js = []
  j = -1
  (0 ... n).each {|t|
    # Step 1
    j += 1
    while j < m && mat[t, j] == 0
      j += 1
    end
    if j >= m
      # TODO if row t doesn't have nonzero entry, we should swap some row with row t.
      break
    end
    js << j
    # Step 2
    (0 ... n).each {|k|
      if k == t
        next
      end
      if mat[k, j] % mat[t, j] == 0
        next
      end
      beta, sigma = ext_gcd(mat[t, j], mat[k, j])
      tau = (beta - mat[t, j] * sigma) / mat[k, j]
      alpha = mat[t, j] / beta
      gamma = mat[k, j] / beta
      row_man = Matrix.build(n, n) { |row, col|
        if row == t && col == t
          alpha
        elsif row == t && col == k
          -tau
        elsif row == k && col == t
          gamma
        elsif row == k && col == k
          sigma
        elsif row == col
          1
        else
          0
        end
      }
      s_mat = s_mat * row_man
      row_man = Matrix.build(n, n) { |row, col|
        if row == t && col == t
          sigma
        elsif row == t && col == k
          tau
        elsif row == k && col == t
          -gamma
        elsif row == k && col == k
          alpha
        elsif row == col
          1
        else
          0
        end
      }
      mat = row_man * mat
    }
    # Step 3
    (0 ... n).each {|k|
      if k == t
        next
      end
      q = mat[k, j] / mat[t, j]
      s_mat = s_mat * elementary_addition(n, k, t, q)
      mat = elementary_addition(n, k, t, -q) * mat
    }
    # TODO We need to interleave Step 2 here
    (j + 1 ... m).each {|k|
      if k == j
        next
      end
      q = mat[t, k] / mat[t, j]
      t_mat = elementary_addition(m, t, k, q) * t_mat
      mat = mat * elementary_addition(m, t, k, -q)
    }
  }
  # Final step, TODO
  (0 ... js.size).each {|r|
    mat = mat * elementary_switch(m, r, js[r])
    t_mat = elementary_switch(m, r, js[r]) * t_mat
  }
  (0 ... js.size).each {|r|
    if mat[r, r] < 0
      mat = mat * elementary_multiplication(m, r, -1)
      t_mat = elementary_multiplication(m, r, -1) * t_mat
    end
  }
    
  [s_mat, mat, t_mat]
end
