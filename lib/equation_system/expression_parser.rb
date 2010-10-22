class EquationSystem
  class ExpressionParser
    TERM_END = /\)|[+-]|\z/
    NUMBER   = /\d+(?:[,\.]\d+)?/
    
    attr_reader :variables
    
    # Parses equations into matrices.
    def self.equations(*equations)
      case equations.first
      when String
        string(*equations)
      when Hash
        hash(*equations)
      when Array
        array(*equations)
      end
    end
    
    # Parses equation strings into matrices.
    def self.string(*equations)
      hash *equations.map { |eq| ExpressionParser.new(eq).variables }
    end
    
    # Parses variable hashes into matrices.
    def self.hash(*equations)
      variable_names = equations.map { |eq| eq.keys }.flatten.uniq
      variable_names.delete(1)
      
      equations.map! do |eq|
        variable_names.each { |var| eq[var] ||= Rational(0) }
        value = Rational(eq.delete(1) || 0)
        eq.sort.map { |symbol, number| number.to_r } << value
      end
      
      return Matrix[*equations], variable_names.sort.map { |name| Variable.new(name) }
    end
    
    # Parses variable arrays into matrices.
    def self.array(*equations)
      return Matrix[*equations].map { |n| n.to_r },
        ('a'..'z').to_a.first(equations[0].length - 1).map { |name| Variable.new(name) }
    end
    
    def initialize(equation)
      @variables = {}
      parse_equation(equation)
    end
    
    protected
    # Parses a plus or minus sign into integer multipliers.
    def parse_sign(sign)
      (sign == '-' ? -1 : 1)
    end
    
    # Parses a string fraction into a Rational object.
    def parse_frac(fraction)
      fraction.split('/').map { |n| parse_decimal(n) }.inject(&:/)
    end
    
    # Parses a string decimal value into a Rational object.
    def parse_decimal(value)
      value = value.to_s.split(/[,\.]/)
      Rational(value.join.to_i, (value.length > 1 ? 10 ** value[-1].length : 1))
    end
    
    private
    # Parses an equation into a variable hash.
    def parse_equation(str)
      left, right = *str.split('=')
      parse_expression(left)
      parse_expression(right, true)
    end
    
    # Parses an expression into a variable hash.
    def parse_expression(expression, negate = false)
      @cache = [ExpressionValue.new(0, negate ? -1 : 1)]
      add_nesting_level
      
      ScanInstructor.scan(expression.gsub(/\s/, '')) do |s|
        s.skip(/\*/)
        
        # Plus/minus sign -> Reset expression cache, and negate if minus.
        s.at(/[+-]/) { |sign| reset_factor(parse_sign(sign)) }
        
        # Constant number -> Write to expression cache.
        s.at(/#{NUMBER}(?:\/#{NUMBER})?/) do |constant|
          constant = parse_frac(constant)
          
          if multiply_backwards(constant).empty?
            @cache[-1] *= constant
            @cache[-1].symbol ||= 1 if s.scanner.check(TERM_END)
          end
        end
        
        # Variable symbol -> Write to expression cache.
        s.at(/[a-zA-Z][a-zA-Z0-9]*/) do |variable|
          @cache[-1].symbol = variable
        end
        
        s.at(/\/#{NUMBER}/) do |denominator|
          multiply_backwards(Rational(1) / parse_decimal(denominator[1..-1]))
        end
        
        # Open parenthesis -> Increase nesting level.
        s.at(/\(/) { add_nesting_level }
        
        # Close prenthesis -> Decrease nesting level and reset cache.
        s.at(/\)/) { remove_nesting_level }
      end
      
      store_values!
    end
    
    # Multiplies the children of the previous parenthesis with the given constant,
    # and returns the elements on which the operation is performed.
    def multiply_backwards(constant)
      @cache[0..-2].reverse.take_while { |factor| factor.level > @cache[-1].level }.each_index do |index|
        @cache[-2 - index] *= constant
      end
    end
    
    # Returns the last factor that is in one nesting level less than the current.
    def factor_at(level)
      @cache.reverse.detect { |factor| factor.level == level }
    end
    
    # Resets the current expression cache to the parent cache, multiplied by a
    # given number.
    def reset_factor(factor = 1)
      @cache << factor_at(@cache[-1].level - 1).next_level * factor
    end
    
    # Adds another level to the nesting stack.
    def add_nesting_level
      @cache << @cache[-1].next_level
    end
    
    # Removes the top-most level of the nesting stack and resets the expression
    # cache.
    def remove_nesting_level
      reset_factor
      @cache[-1] = @cache[-1].prev_level
    end
    
    # Accumulates all the parsed values of the expression cache and saves them.
    def store_values!
      @cache.group_by(&:symbol).reject { |symbol, value| symbol.nil? }.each do |symbol, value|
        @variables[symbol] ||= Rational(0)
        @variables[symbol] += value.map(&:constant).inject(&:+) * (symbol == 1 ? -1 : 1)
      end
    end
    
  end
end
