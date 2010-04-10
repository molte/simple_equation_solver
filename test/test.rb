require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'equation_system')
require File.join(File.dirname(__FILE__), 'test_helper')

class EquationSolverTest < Test::Unit::TestCase
  extend TestHelper
  
  equation_system :simple do
    equation "a = 1 - b"
    equation "4 + a = 2a"
    solution 'a' => 4, 'b' => -3
  end
  
  equation_system :advanced do
    equation "4x - 5y + 3z - y = 9"
    equation "3x - 3y + 8z = 22 + 2y"
    equation "5x - 5 + 4y - 7z = 20"
    solution 'x' => 6, 'y' => 4, 'z' => 3
  end
  
  equation_system :hash do
    equation 'x' => 4, 'y' => -6, 'z' => 3, :equals => 9
    equation 'x' => 3, 'y' => -5, 'z' => 8, :equals => 22
    equation 'x' => 5, 'y' => 4, 'z' => -7, :equals => 25
    solution 'x' => 6, 'y' => 4, 'z' => 3
  end
  
  equation_system :array do
    equation [1, 2, 1, 2]
    equation [3, 8, 1, 12]
    equation [0, 4, 1, 2]
    solution 'a' => 2, 'b' => 1, 'c' => -2
  end
  
  equation_system :other_names do
    equation "u + v + w = 9"
    equation "u + 2v + 4w = 15"
    equation "u + 3v + 9w = 23"
    solution 'u' => 5, 'v' => 3, 'w' => 1
  end
  
  equation_system :with_parens do
    equation "x + y = 10"
    equation "(x + 2 - (5 + y)) = 5 - (2x - x)"
    solution 'x' => 6, 'y' => 4
  end
  
  equation_system :with_unordered_rows do
    equation "x + 2y + z = 2"
    equation "5z = -10"
    equation "2y - 2z = 6"
    solution 'x' => 2, 'y' => 1, 'z' => -2
  end
end
