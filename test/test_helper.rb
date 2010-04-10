module TestHelper
  def equation_system(name, &block)
    tester = EquationSystemTest.new(name)
    tester.instance_eval(&block)
    tester.test(self)
  end
  
  class EquationSystemTest
    def initialize(name)
      @equations = []
      @name = name
    end
    
    def equation(eq)
      @equations << eq
    end
    
    def solution(variables)
      @solution = variables
    end
    
    def test(test_class)
      test_class.class_eval <<-EOT
        def test_#{@name}_equation_system
          assert_equal(#{@solution.inspect}, EquationSystem.new(*#{@equations.inspect}).solution, "Equation system could not be solved.")
        end
      EOT
    end
  end
end
