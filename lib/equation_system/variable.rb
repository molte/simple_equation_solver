class EquationSystem
  class Variable
    attr_reader :name, :value
    
    def initialize(name, value = {})
      @name = name.to_s
      @value = (value.is_a?(Numeric) ? {1 => value} : value)
    end
    
    # Returns a new Variable object with the value represented as objects of Float,
    # rounded to the given precision.
    def with_float_value(precision = 2)
      Variable.new(@name, @value.map_values { |n| n.to_f.round(precision) })
    end
    
    # Returns a new variable as the sum of the current and given values.
    def +(addend)
      case addend
      when Numeric
        self + {1 => addend}
      else
        sum = @value.merge(addend) { |k, v1, v2| v1 + v2 }
        Variable.new(@name, sum)
      end
    end
    
    # Returns whether a value is given.
    def has_value?
      !value.empty?
    end
    
    def to_s
      has_value? ? ("#{@name} = " + sorted_value.map(&:to_s).join(" + ")).gsub("+ -", "- ") : ""
    end
    
    def to_html
      self.to_s.gsub(/[a-zA-Z]+/, '<var>\0</var>').gsub(/(-?\d+)\/(\d+)/,
        '<span class="fraction"><span class="numerator">\1</span><span class="divider">/</span><span class="denominator">\2</span></span>').gsub("-", "&minus;")
    end
    
    def to_hash
      {@name => @value}
    end
    
    private
    # Returns an array of the constant followed by arrays of coefficient-symbol pairs.
    def sorted_value
      symbol_format = lambda { |symbol, number| number == 1 ? symbol : (number == -1 ? "-#{symbol}" : [number, symbol]) }
      @value.except(1).sort.map(&symbol_format).unshift(@value[1]).reject { |number, symbol| number.is_a?(Numeric) && number.zero? }.presence || [0]
    end
  end
end
