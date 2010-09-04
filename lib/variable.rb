class Variable
  attr_reader :name, :value
  
  def initialize(name, value = {})
    @name = name.to_s
    @value = (value.is_a?(Numeric) ? {1 => value.to_f} : value)
  end
  
  def +(addend)
    case addend
    when Numeric
      self + {1 => addend}
    else
      sum = @value.merge(addend) { |k, v1, v2| v1 + v2 }
      Variable.new(@name, sum)
    end
  end
  
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
  def sorted_value
    @value.except(1).map(&:reverse).unshift(@value[1]).reject { |number, symbol| number.zero? }
  end
end
