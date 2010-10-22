class EquationSystem
  class ExpressionValue
    attr_accessor :level, :constant, :symbol
    
    def initialize(nesting_level, number, symbol = nil)
      @level, @constant, @symbol = nesting_level, number, symbol
    end
    
    # Returns the value with multiplied by the given factor.
    def *(factor)
      ExpressionValue.new(@level, @constant * factor, @symbol)
    end
    
    # Returns the value with the nesting level increased by one.
    def next_level
      ExpressionValue.new(@level + 1, @constant, @symbol)
    end
    
    # Returns the value with the nesting level decreased by one.
    def prev_level
      ExpressionValue.new(@level - 1, @constant, @symbol)
    end
  end
end
