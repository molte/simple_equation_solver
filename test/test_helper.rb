require 'rubygems'
require 'active_support/core_ext/object/blank'

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
      case variables
      when Hash
        @expected_solution_hash = variables.map { |k, v| EquationSystem::Variable.new(k, v).to_hash }.inject(&:merge)
      when String
        @expected_solution_string = variables
      end
    end
    
    def test(test_class)
      method_name = (@name.to_s.start_with?('with') ? "test_equation_system_#{@name}" : "test_#{@name}_equation_system")
      test_class.class_eval <<-EOT
        def #{method_name}
          solution = EquationSystem.new(*#{@equations.inspect}).solution
          assert_equal(#{@expected_solution_hash.inspect}, solution.map(&:to_hash).inject(&:merge), "Equation system could not be solved; hashes are not identical.")
          assert_equal(#{@expected_solution_string.inspect}, solution.map(&:to_s).reject(&:blank?).sort.join(", "), "Equation system could not be solved; strings are not identical.")
        end
      EOT
    end
  end
end
