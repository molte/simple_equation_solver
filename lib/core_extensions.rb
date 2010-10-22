class Matrix
  # Exchanges two rows of the matrix.
  def permutate!(i1, i2)
    @rows[i1], @rows[i2] = @rows[i2], @rows[i1]
    return self
  end
  
  def []=(i, j, value)
    @rows[i][j] = value
  end
  
  # Uses the Gauss-Jordan algorithm to reduce the matrix to reduced row-echelon form.
  def reduced_row_echelon_form
    (0...min_dimension).inject(clone) do |matrix, j|
      eliminate_row(matrix, j)
    end
  end
  
  private
  # Eliminates the row at the given index of the given matrix.
  def eliminate_row(matrix, j)
    (j...row_size).each do |p|
      matrix.permutate!(j, p) && break unless matrix[p, j].zero?
      return matrix if (p + 1) == row_size
    end
    
    eliminator = Matrix.identity(row_size)
    eliminator[j, j] = 1 / matrix[j, j]
    
    row_size.times do |q|
      eliminator[q, j] = -(matrix[q, j] / matrix[j, j]) if q != j
    end
    
    eliminator * matrix
  end
  
  # Returns the smalles dimension of the matrix.
  def min_dimension
    [row_size, column_size].min
  end
end

class Hash
  # Iterates through each value of the hash and replaces it with the result of the given block.
  def map_values
    inject({}) { |hash, (key, value)| hash[key] = yield(value); hash }
  end
end
