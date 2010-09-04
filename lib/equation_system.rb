require 'matrix'
require 'rubygems'
require 'active_support/core_ext'
require File.join(File.dirname(__FILE__), 'core_extensions')
require File.join(File.dirname(__FILE__), 'variable')

# The EquationSystem class is able to solve a system of n first-degree equations with n unknown variables.
# Requirements:
#  - The equations may only contain variables with coefficients (eg. 4z) and numbers.
#  - All numbers should be rational, written with decimal-notation.
#  - The only allowed operators are plus and minus (except the hidden multiplication sign between the coefficient and the variable).
# Requires Ruby version 1.8.7.
class EquationSystem
  VariablePattern = /([\d\.]+)?([a-zA-Z])/
  ConstantPattern = /([\d\.]+)/
  
  def initialize(*equations)
    raise "EquationSystem only works with ruby version 1.8.7." unless RUBY_VERSION == "1.8.7"
    @equations, @variables = case equations.first
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
    solve! unless @solved
    # raise "The equations could not be solved." unless finite_solution?
    @variables
  end
  
  # Checks whether the solution is valid.
  def valid_solution?
    a, b = split_equations
    a * Matrix.column_vector(@variables.map(:value)) == b
  end
  
  # Checks whether the solution only consists of finite numbers.
  def finite_solution?
    @variables.map(:value).all? { |v| v[1].finite? }
  end
  
  def consistent?
    @equations.to_a.none? do |row|
      row.to(-2).all?(&:zero?) && !row[-1].zero?
    end
  end
  
  private
  # Returns the number of equations in the system.
  def m; @equations.row_size end
  
  # Returns the number of variables in the system.
  def n; @equations.column_size - 1 end
  
  # Solves the equations with elimination and back substitution.
  def solve!
    eliminate!
    raise "The equations could not be solved." unless consistent?
    back_substitute!
    @solved = true
  end
  
  # Uses Gaussian elimination to reduce the equations to reduced row-echelon form.
  def eliminate!
    [m, n].min.times do |j|
      eliminate_row!(j)
    end
  end
  
  def eliminate_row!(j)
    (j...m).each do |p|
        @equations.permutate!(j, p) && break unless @equations[p, j].zero?
        return if (p + 1) == m
      end
      
      elimination_matrix = Matrix.identity(m)
      elimination_matrix[j, j] = 1.0 / @equations[j, j]
      
      m.times do |q|
        elimination_matrix[q, j] = -(@equations[q, j] / @equations[j, j]) if q != j
      end
      
      @equations = elimination_matrix * @equations
  end
  
  # Uses back substitution to compute the variable values.
  def back_substitute!
    equations_without_zero_rows.each_with_index do |row, i|
      @variables[i] += row[-1]
      ((i + 1)...n).each do |j|
        @variables[i] += {@variables[j].name => -row[j]} unless row[j].zero?
      end
    end
  end
  
  # Returns the equations as a nested array excluding the all-zero rows.
  def equations_without_zero_rows
    @equations.to_a.reject { |row| row.all?(&:zero?) }
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
    variables[1] ||= 0
    
    str.scan(/(\A|[+-])(\(?)(?:#{VariablePattern}|#{ConstantPattern})(\)*)(?=[+-]|\z)/) do |sign, open_paren, coefficient, variable, constant, close_paren|
      negation = nesting_level[-1] * parse_sign(sign)
      
      if variable
        variables[variable] ||= 0
        variables[variable] += (coefficient || '1').to_f * negation
      else
        variables[1] -= constant.to_f * negation
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
    variable_names.delete(1)
    
    equations.map! do |eq|
      variable_names.each { |var| eq[var] ||= 0.0 }
      value = eq.delete(1).to_f
      eq.values.map { |n| n.to_f } << value
    end
    
    return Matrix[*equations], variable_names.map { |name| Variable.new(name) }
  end
  
  # Parses variable arrays into matrices.
  def from_array(*equations)
    return Matrix[*equations].map { |n| n.to_f },
      ('a'..'z').to_a.first(equations[0].length - 1).map { |name| Variable.new(name) }
  end
end
