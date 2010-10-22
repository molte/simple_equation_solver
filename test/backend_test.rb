require 'test/unit'
require File.dirname(__FILE__) + '/../lib/equation_system'
require File.dirname(__FILE__) + '/test_helper'

class EquationSolverTest < Test::Unit::TestCase
  extend TestHelper
  
  equation_system :simple do
    equation "a = 1 - b"
    equation "4 + a = 2a"
    
    solution 'a' => 4, 'b' => -3
    solution "a = 4, b = -3"
  end
  
  equation_system :advanced do
    equation "4x - 5y + 3z - y = 9"
    equation "3x - 3y + 8z = 22 + 2y"
    equation "5x - 5 + 4y - 7z = 20"
    
    solution 'x' => 6, 'y' => 4, 'z' => 3
    solution "x = 6, y = 4, z = 3"
  end
  
  equation_system :hash do
    equation 'x' => 4, 'y' => -6, 'z' => 3, 1 => 9
    equation 'x' => 3, 'y' => -5, 'z' => 8, 1 => 22
    equation 'x' => 5, 'y' => 4, 'z' => -7, 1 => 25
    
    solution 'x' => 6, 'y' => 4, 'z' => 3
    solution "x = 6, y = 4, z = 3"
  end
  
  equation_system :array do
    equation [1, 2, 1, 2]
    equation [3, 8, 1, 12]
    equation [0, 4, 1, 2]
    
    solution 'a' => 2, 'b' => 1, 'c' => -2
    solution "a = 2, b = 1, c = -2"
  end
  
  equation_system :with_other_names do
    equation "u + v + w = 9"
    equation "u + 2v + 4w = 15"
    equation "u + 3v + 9w = 23"
    
    solution 'u' => 5, 'v' => 3, 'w' => 1
    solution "u = 5, v = 3, w = 1"
  end
  
  equation_system :with_parens do
    equation "x + y = 10"
    equation "(x + 2 - (5 + y)) = 5 - (2x - x)"
    
    solution 'x' => 6, 'y' => 4
    solution "x = 6, y = 4"
  end
  
  equation_system :with_unordered_rows do
    equation "x + 2y + z = 2"
    equation "5z = -10"
    equation "2y - 2z = 6"
    
    solution 'x' => 2, 'y' => 1, 'z' => -2
    solution "x = 2, y = 1, z = -2"
  end
  
  equation_system :with_multiple_solutions do
    equation "x - y + z = 1"
    equation "x + y - z = 2"
    
    solution 'x' => Rational(3, 2), 'y' => {1 => Rational(1, 2), 'z' => 1}, 'z' => {}
    solution "x = 3/2, y = 1/2 + z"
  end
  
  equation_system :homogeneous do
    equation "-3a + b + c + d = 0"
    equation "a - 3b + c + d = 0"
    equation "a + b - 3c + d = 0"
    equation "a + b + c - 3d = 0"
    
    solution 'a' => {1 => 0, 'd' => 1}, 'b' => {1 => 0, 'd' => 1}, 'c' => {1 => 0, 'd' => 1}, 'd' => {}
    solution "a = d, b = d, c = d"
  end
  
  equation_system :with_fractional_input do
    equation "b = 1/2a + 3/4"
    equation "a = 7/5"
    
    solution 'a' => Rational(7, 5), 'b' => Rational(29, 20)
    solution "a = 7/5, b = 29/20"
  end
  
  equation_system :with_long_variable_names do
    equation "var1 + var2 = 45var2"
    equation "5 - (7var2 + 3) = 23"
    
    solution 'var1' => -132, 'var2' => -3
    solution "var1 = -132, var2 = -3"
  end
  
  equation_system :with_decimal_values do
    equation "1/2s + 4.5t = 1.5/3.0"
    
    solution 's' => {1 => 1, 't' => -9}, 't' => {}
    solution "s = 1 - 9t"
  end
  
  equation_system :with_comma_notation do
    equation "1.5x = 3,5"
    
    solution'x' => Rational(7, 3)
    solution "x = 7/3"
  end
  
  equation_system :with_multiplication_signs do
    equation "2 * x = 4"
    
    solution 'x' => 2
    solution "x = 2"
  end
  
  equation_system :with_advanced_multiplication do
    equation "2 * 4 = 0 + 3(7*x - 2)"
    
    solution 'x' => Rational(2, 3)
    solution "x = 2/3"
  end
  
  equation_system :inconsistent do
    equation "2x + 2y - 2z = 5"
    equation "7x + 7y + z = 10"
    equation "5x + 5y - z =  5"
    
    solution 'x' => {1 => Rational(155, 116), 'y' => -1}, 'y' => {}, 'z' => Rational(-45, 116)
    solution "x = 155/116 - y, z = -45/116"
  end
end
