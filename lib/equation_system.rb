require 'matrix'
require 'rational'

require File.dirname(__FILE__) + '/core_extensions'
require File.dirname(__FILE__) + '/equation_system/variable'
require File.dirname(__FILE__) + '/equation_system/expression_parser'

# The EquationSystem class is able to solve a system of m unordered first-degree linear equations with n unknown variables.
# (requires Ruby 1.8.7)
class EquationSystem
  def initialize(*equations)
    raise "EquationSystem only works with ruby version 1.8.7." unless RUBY_VERSION == "1.8.7"
    @equations, @variables = ExpressionParser.equations(*equations)
  end
  
  # Solves the equations and returns the solution as a hash.
  def solution(notation = :rational)
    solve! unless @solved
    notation == :decimal ? @variables.map { |var| var.with_float_value } : @variables
  end
  
  # Returns whether the solution is exact or just an approximation.
  def approximation?; @approx end
  
  private
  # Returns the number of equations in the system.
  def m; @equations.row_size end
  
  # Returns the number of variables in the system.
  def n; @equations.column_size - 1 end
  
  # Solves the equations with elimination and back substitution.
  def solve!
    equations = @equations.reduced_row_echelon_form
    back_substitute!(consistent?(equations) ? equations : normal_equations)
    @solved = true
  end
  
  # Finds the least squares solution by pre-multiplying the augmented matrix with the transpose of the coefficient matrix.
  def normal_equations
    @approx = true
    (Matrix[*@equations.to_a.transpose[0..-2]] * @equations).reduced_row_echelon_form
  end
  
  # Checks whether the system of equations is solvable.
  # This method should only be called after elimination.
  def consistent?(equations)
    equations.to_a.none? do |row|
      row[0..-2].all?(&:zero?) && !row[-1].zero?
    end
  end
  
  # Uses back substitution to compute the variable values.
  def back_substitute!(equations)
    equations.to_a.each_with_index do |row, i|
      next if row[i].zero?
      @variables[i] += row[-1]
      ((i + 1)...n).each do |j|
        @variables[i] += {@variables[j].name => -row[j]} unless row[j].zero?
      end
    end
  end
end
