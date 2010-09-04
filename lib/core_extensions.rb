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
