require 'matrix'

class EquationSystem
  def initialize(*equations)
    @coefficients, @variable_names, @values = case equations.first
    when String
      from_string(*equations)
    when Hash
      from_hash(*equations)
    when Array
      from_array(*equations)
    end
  end
  
  def solution
    solve!
    return Hash[*[@variable_names, @variable_values].transpose.flatten]
  end
  
  private
  def solve!
    eliminate!
    
    # Ux = c
    u = @coefficients.to_a.transpose
    c = @values.to_a.map { |v| v.first }
    x = Array.new(u.length)
    
    u.reverse.each_with_index do |column, index|
      column_number = u.length - index - 1
      
      x[column_number] = c[column_number] / column[column_number]
      
      column_number.times do |row_number|
        c[row_number] -= column[row_number] * x[column_number]
      end
    end
    
    @variable_values = x
  end
  
  def eliminate!
    @coefficients.column_size.times do |column|
      pivot = @coefficients[column, column]
      
      (column + 1).upto(@coefficients.row_size - 1) do |row|
        target = @coefficients[row, column]
        factor = target / pivot
        
        elimination_matrix = Matrix.identity(@coefficients.column_size)
        elimination_matrix[row, column] = -factor
        
        @coefficients = elimination_matrix * @coefficients
        @values = elimination_matrix * @values
      end
    end
  end
  
  def from_string(*equations)
    equations.map! do |eq|
      eq_hash = {}
      left, right = *eq.gsub(/[^0-9a-zA-Z=\+-]/, '').split('=')
      
      find_variables(left, eq_hash)
      find_variables(right, eq_hash, true)
      eq_hash[:equals] = find_constants(right) + find_constants(left, true)
      
      eq_hash
    end
    from_hash(*equations)
  end
  
  def find_variables(str, variables = {}, negate = false)
    str.scan(/(-)?([\d\.]+)?([a-zA-Z])/) do |sign, number, variable|
      variables[variable] ||= 0
      variables[variable] += (sign.to_s + (number || '1')).to_f * (negate ? -1 : 1)
    end
    variables
  end
  
  def find_constants(str, negate = false)
    total = 0
    str.scan(/(-?[\d\.]+)(?:[\+-]|\z)/) do |number, x|
      total += number.to_f * (negate ? -1 : 1)
    end
    total
  end
  
  def from_hash(*equations)
    variable_names = equations.map { |eq| eq.keys }.flatten.uniq
    variable_names.delete(:equals)
    
    values = []
    equations.map! do |eq|
      values << eq.delete(:equals).to_f
      variable_names.each { |var| eq[var] ||= 0 }
      eq.values.map { |n| n.to_f }
    end
    
    return Matrix[*equations], variable_names, Matrix.column_vector(values)
  end
  
  def from_array(*equations)
    values = []
    equations.each do |eq|
      values << eq.delete_at(-1)
    end
    return Matrix[*equations].map { |n| n.to_f }, ('a'..'z').to_a.first(equations.length), Matrix.column_vector(values.map { |n| n.to_f })
  end
end

class Matrix
  def []=(i, j, value)
    @rows[i][j] = value
  end
end

if $0 == __FILE__
  puts EquationSystem.new([1, 2, 1, 2], [3, 8, 1, 12], [0, 4, 1, 2]).solution.inspect
  puts EquationSystem.new({'x' => 1, 'y' => 2, 'z' => 1, :equals => 2}, {'x' => 3, 'y' => 8, 'z' => 1, :equals => 12}, {'y' => 4, 'z' => 1, :equals => 2}).solution.inspect
  puts EquationSystem.new("x + 2y + z = 2", "3x + 8y + z = 12", "4y + z = 2").solution.inspect
  puts EquationSystem.new([4, -6, 3, 9], [3, -5, 8, 22], [5, 4, -7, 25]).solution.inspect
  puts EquationSystem.new({'x' => 4, 'y' => -6, 'z' => 3, :equals => 9}, {'x' => 3, 'y' => -5, 'z' => 8, :equals => 22}, {'x' => 5, 'y' => 4, 'z' => -7, :equals => 25}).solution.inspect
  puts EquationSystem.new("4x - 6y + 3z = 9", "3x - 5y + 8z = 22", "5x + 4y - 7z = 25").solution.inspect
  puts EquationSystem.new("4x - 5y + 3z - y = 9", "3x - 3y + 8z = 22 + 2y", "5x - 5 + 4y - 7z = 20").solution.inspect
end
