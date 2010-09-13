require 'matrix'
require 'rational'
require 'rubygems'
require 'active_support/core_ext'
require File.join(File.dirname(__FILE__), 'core_extensions')
require File.join(File.dirname(__FILE__), 'equation_system', 'variable')
require File.join(File.dirname(__FILE__), 'equation_system', 'expression_parser')

# The EquationSystem class is able to solve a system of m unordered first-degree linear equations with n unknown variables.
# Requirements:
#  - The equations may only contain variables with coefficients (eg. 4z) and numbers.
#  - All numbers should be rational.
# Requires Ruby version 1.8.7.
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
  
  # Uses the Gauss-Jordan algorithm to reduce the equations to reduced row-echelon form.
  def eliminate!
    [m, n].min.times do |j|
      eliminate_row!(j)
    end
  end
  
  # Eliminates for the given column number.
  def eliminate_row!(j)
    (j...m).each do |p|
        @equations.permutate!(j, p) && break unless @equations[p, j].zero?
        return if (p + 1) == m
      end
      
      elimination_matrix = Matrix.identity(m)
      elimination_matrix[j, j] = 1 / @equations[j, j]
      
      m.times do |q|
        elimination_matrix[q, j] = -(@equations[q, j] / @equations[j, j]) if q != j
      end
      
      @equations = elimination_matrix * @equations
  end
  
  # Checks whether the system of equations is solvable.
  # This method should only be called after elimination.
  def consistent?
    @equations.to_a.none? do |row|
      row.to(-2).all?(&:zero?) && !row[-1].zero?
    end
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
end
