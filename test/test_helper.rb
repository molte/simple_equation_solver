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
      @expected_solution = variables.map { |k, v| Variable.new(k, v).to_hash }.inject(:merge)
    end
    
    def test(test_class)
      test_class.class_eval <<-EOT
        def test_#{@name}_equation_system
          solution = EquationSystem.new(*#{@equations.inspect}).solution.map(&:to_hash).inject(:merge)
          assert_equal(#{@expected_solution.inspect}, solution, "Equation system could not be solved.")
        end
      EOT
    end
  end
end
