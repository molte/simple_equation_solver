require 'matrix'
require File.join(File.dirname(__FILE__), 'core_extensions')

# The EquationSystem class is able to solve a system of n first-degree equations with n unknown variables.
# Requirements:
#  - The equations may only contain variables with coefficients (eg. 4z) and numbers.
#  - All numbers should be rational, written with decimal-notation.
#  - The only allowed operators are plus and minus (except the hidden multiplication sign between the coefficient and the variable).
# Requires ruby version 1.8.7 or greater.
class EquationSystem
  VariablePattern = /([\d\.]+)?([a-zA-Z])/
  ConstantPattern = /([\d\.]+)/
  
  def initialize(*equations)
    raise "EquationSystem only works with ruby version 1.8.7 or greater." if RUBY_VERSION < "1.8.7"
    @equations, @variable_names = case equations.first
    when String
      from_string(*equations)
    when Hash
      from_hash(*equations)
    when Array
      from_array(*equations)
    end
  end
  
  # Solves the equations and returns the solution as a hash.
  def solution
    solve!
    raise "The equations could not be solved." unless finite_solution?
    return Hash[*[@variable_names, @variable_values].transpose.flatten]
  end
  
  # Checks whether the solution is valid.
  def valid_solution?
    a, b = split_equations
    a * Matrix.column_vector(@variable_values) == b
  end
  
  # Checks whether the solution only consists of finite numbers.
  def finite_solution?
    @variable_values.each { |v| return false unless v.finite? }
    return true
  end
  
  private
  # Solves the equations with elimination and back substitution.
  def solve!
    raise "The number of unkown does not match the number of equations." unless (@equations.column_size - 1) == @equations.row_size
    raise "The equations are not linear indepdendent." unless @equations.rank == (@equations.column_size - 1)
    
    eliminate!
    @variable_values = back_substitute
  end
  
  # Uses Gaussian elimination to reduce the equations.
  def eliminate!
    (@equations.column_size - 1).times do |j|
      i2 = j
      while (pivot = @equations[j, j]).zero?
        i2 += 1
        raise "No more rows to exchange with to avoid a zero pivot." if @equations.row_size <= i2
        @equations.permutate!(j, i2)
      end
      
      (j + 1).upto(@equations.row_size - 1) do |i|
        target = @equations[i, j]
        factor = target / pivot
        
        elimination_matrix = Matrix.identity(@equations.row_size)
        elimination_matrix[i, j] = -factor
        
        @equations = elimination_matrix * @equations
      end
    end
  end
  
  # Uses back substitution to compute the variable values.
  def back_substitute
    # Ux = c
    u = @equations.to_a.transpose
    c = u.delete_at(-1)
    x = Array.new(u.length)
    
    u.reverse.each_with_reversed_index do |column, j|
      x[j] = c[j] / column[j]
      j.times { |i| c[i] -= column[i] * x[j] }
    end
    return x
  end
  
  # Splits the equations into the left and right-hand side. Returns them as matrices.
  def split_equations
    a = @equations.to_a.transpose
    b = a.delete_at(-1)
    return Matrix.rows(a.transpose), Matrix.column_vector(b)
  end
  
  # Parses equation strings into variable hashes.
  def from_string(*equations)
    from_hash *equations.map { |eq| parse_equation(eq) }
  end
  
  # Parses an equation into a variable hash.
  def parse_equation(str)
    left, right = *str.gsub(/[^0-9a-zA-Z()=+-]/, '').split('=')
    parse_expression(right, parse_expression(left), true)
  end
  
  # Parses an expression into a variable hash.
  def parse_expression(str, variables = {}, negate = false)
    nesting_level = [negate ? -1 : 1]
    variables[:equals] ||= 0
    
    str.scan(/(\A|[+-])(\(?)(?:#{VariablePattern}|#{ConstantPattern})(\)*)(?=[+-]|\z)/) do |sign, open_paren, coefficient, variable, constant, close_paren|
      negation = nesting_level[-1] * parse_sign(sign)
      
      if variable
        variables[variable] ||= 0
        variables[variable] += (coefficient || '1').to_f * negation
      else
        variables[:equals] -= constant.to_f * negation
      end
      
      nesting_level << negation unless open_paren.empty?
      nesting_level.pop(close_paren.length) unless close_paren.empty?
    end
    
    variables
  end
  
  # Parses a plus or minus sign into integer multipliers.
  def parse_sign(sign)
    (sign == '-' ? -1 : 1)
  end
  
  # Parses variable hashes into martices.
  def from_hash(*equations)
    variable_names = equations.map { |eq| eq.keys }.flatten.uniq
    variable_names.delete(:equals)
    
    equations.map! do |eq|
      variable_names.each { |var| eq[var] ||= 0 }
      value = eq.delete(:equals).to_f
      eq.values.map { |n| n.to_f } << value
    end
    
    return Matrix[*equations], variable_names
  end
  
  # Parses variable arrays into matrices.
  def from_array(*equations)
    return Matrix[*equations].map { |n| n.to_f }, ('a'..'z').to_a.first(equations.length)
  end
end
