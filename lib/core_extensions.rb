class Matrix
  # Exchanges two rows of the matrix.
  def permutate!(i1, i2)
    @rows[i1], @rows[i2] = @rows[i2], @rows[i1]
    return self
  end
  
  def []=(i, j, value)
    @rows[i][j] = value
  end
end

class Hash
  # Iterates through each value of the hash and replaces it with the result of the given block.
  def map_values
    inject({}) { |hash, (key, value)| hash[key] = yield(value) }
  end
end
