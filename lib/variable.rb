class Variable
  attr_reader :name, :value
  
  def initialize(name, value = {})
    @name = name.to_s
    @value = (value.is_a?(Numeric) ? {1 => value.to_f} : value)
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
    self.to_s.gsub("-", "&minus;").gsub(/[a-zA-Z]/, "<var>\\0</var>")
  end
  
  def to_hash
    {@name => @value}
  end
  
  private
  # Returns an array of the constant followed by arrays of coefficient-symbol pairs.
  def sorted_value
    symbol_format = lambda { |symbol, number| number == 1 ? symbol : (number == -1 ? "-#{symbol}" : [number, symbol]) }
    @value.except(1).sort.map(&symbol_format).unshift(@value[1]).reject { |number, symbol| number.is_a?(Numeric) && number.zero? }.presence || [0.0]
  end
end
