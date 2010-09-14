class EquationSystem
  class ExpressionValue
    attr_accessor :constant, :variable
    
    def initialize(number, symbol = 1)
      @constant, @variable = number, symbol
    end
    
    def *(factor)
      ExpressionValue.new(@constant * factor, @variable)
    end
  end
end
