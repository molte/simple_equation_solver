class Matrix
  # Exchanges two rows of the matrix.
  def permutate!(i1, i2)
    row = @rows[i1]
    @rows[i1] = @rows[i2]
    @rows[i2] = row
    return self
  end
  
  def []=(i, j, value)
    @rows[i][j] = value
  end
end

class Array
  def each_with_reversed_index
    self.each_with_index do |item, index|
      reversed_index = self.length - index - 1
      yield(item, reversed_index)
    end
  end
end
