class EquationSystem
  class ExpressionParser
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
      @scanner = StringScanner.new(expression.gsub(/\s/, ''))
      @factors = [negate ? -1 : 1]
      add_nesting_level
      
      until @scanner.eos?
        @scanner.skip(/\*/)
        unless parse_term || parse_constant || parse_variable || parse_open_paren || parse_close_paren
          raise "Invalid expression syntax; unregocnized character used (#{@scanner.peek(1).inspect})."
        end
      end
      
      @variables
    end
    
    # When a plus or minus sign is present, resets the expression factor to the
    # factor at the previous nesting level, negated if the sign is a minus
    # sign.
    def parse_term
      sign = @scanner.scan(/[+-]/) and reset_factor(parse_sign(sign))
    end
    
    # When a constant number is present, multiplies the expression factor with
    # that number and save it if it is not a factor of a product or it is the
    # last of such.
    def parse_constant
      constant = @scanner.scan(/[\d\/,\.]+/) and update_factor(constant)
    end
    
    # When a variable symbol is present, store it together with its
    # coefficients and resets the expression factor.
    def parse_variable
      variable = @scanner.scan(/[a-zA-Z][a-zA-Z0-9]*/) and store_value(variable)
    end
    
    # When an open parenthesis is present next in the expression, goes a
    # nesting level deeper.
    def parse_open_paren
      @scanner.scan(/\(/) and add_nesting_level
    end
    
    # When a closing parenthesis is present next in the expression, goes back a
    # level in the nesting stack and resets the expression factor.
    def parse_close_paren
      @scanner.scan(/\)/) and remove_nesting_level
    end
    
    # Multiplies the expression factor with the given number and saves the
    # value if the number is the last in the current term.
    def update_factor(number, negate = false)
      @factors[-1] *= parse_frac(number)
      if @scanner.check(/\)|[+-]|\z/)
        @factors[-1] *= -1
        store_value(1)
      end
      return true
    end
    
    # Resets the current expression factor to the factor at the previous
    # nesting level, multiplied by a given number.
    def reset_factor(multiplier = 1)
      @factors[-1] = @factors[-2] * multiplier
    end
    
    # Adds another level to the nesting stack, where the new expression factor
    # is identical to the previous.
    def add_nesting_level
      @factors << @factors[-1]
    end
    
    # Removes the top-most level of the nesting stack and resets the expression
    # factor.
    def remove_nesting_level
      @factors.pop
      reset_factor
    end
    
    # Stores the variable value in the proper hash and resets the expression
    # factor.
    def store_value(variable)
      @variables[variable] ||= Rational(0)
      @variables[variable] += @factors[-1]
      reset_factor
    end
    
  end
end
