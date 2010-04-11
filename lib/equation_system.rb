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
    @coefficients, @variable_names, @values = case equations.first
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
    raise "The equations could not be solved" unless finite_solution?
    return Hash[*[@variable_names, @variable_values].transpose.flatten]
  end
  
  # Checks whether the solution is valid.
  def valid_solution?
    @coefficients * Matrix.column_vector(@variable_values) == @values
  end
  
  # Checks whether the solution only consists of finite numbers.
  def finite_solution?
    @variable_values.each { |v| return false unless v.finite? }
    return true
  end
  
  private
  # Solves the equations with elimination and back substitution.
  def solve!
    eliminate!
    
    # Ux = c
    u = @coefficients.to_a.transpose
    x = Array.new(u.length)
    c = @values.to_a.map { |v| v.first }
    
    u.reverse.each_with_reversed_index do |column, column_number|
      x[column_number] = c[column_number] / column[column_number]
      
      column_number.times do |row_number|
        c[row_number] -= column[row_number] * x[column_number]
      end
    end
    
    @variable_values = x
  end
  
  # Uses Gaussian elimination to reduce the equations.
  def eliminate!
    @coefficients.column_size.times do |column|
      i2 = column
      while (pivot = @coefficients[column, column]).zero?
        i2 += 1
        raise "No more rows to exchange with to avoid a zero pivot." if @coefficients.row_size <= i2
        @coefficients.permutate!(column, i2)
        @values.permutate!(column, i2)
      end
      
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
    
    values = []
    equations.map! do |eq|
      values << eq.delete(:equals).to_f
      variable_names.each { |var| eq[var] ||= 0 }
      eq.values.map { |n| n.to_f }
    end
    
    return Matrix[*equations], variable_names, Matrix.column_vector(values)
  end
  
  # Parses variable arrays into matrices.
  def from_array(*equations)
    values = []
    equations.each do |eq|
      values << eq.delete_at(-1)
    end
    return Matrix[*equations].map { |n| n.to_f }, ('a'..'z').to_a.first(equations.length), Matrix.column_vector(values.map { |n| n.to_f })
  end
end
