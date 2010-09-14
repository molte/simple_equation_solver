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
      @cache = [ExpressionValue.new(negate ? -1 : 1)]
      add_nesting_level
      
      until @scanner.eos?
        @scanner.skip(/\*/)
        unless parse_term || parse_constant || parse_variable || parse_open_paren || parse_close_paren
          raise "Invalid expression syntax; unregocnized character used (#{@scanner.peek(1).inspect})."
        end
      end
      
      @variables
    end
    
    # Scans for a plus or minus sign in the expression. On success, resets the
    # expression cache and negate if minus.
    def parse_term
      sign = @scanner.scan(/[+-]/) and reset_factor(parse_sign(sign))
    end
    
    # Scans for a constant number in the expression and caches it.
    def parse_constant
      constant = @scanner.scan(/[\d\/,\.]+/) and update_factor(constant)
    end
    
    # Scans for a variable symbol in the expression and caches it.
    def parse_variable
      variable = @scanner.scan(/[a-zA-Z][a-zA-Z0-9]*/) and update_variable(variable)
    end
    
    # When an open parenthesis is present next in the expression, goes a
    # nesting level deeper.
    def parse_open_paren
      @scanner.scan(/\(/) and add_nesting_level
    end
    
    # When a closing parenthesis is present next in the expression, goes back a
    # level in the nesting stack and resets the expression cache.
    def parse_close_paren
      @scanner.scan(/\)/) and remove_nesting_level
    end
    
    # Multiplies the current expression cache with the given number and saves
    # the value if necessary.
    def update_factor(number)
      @cache[-1] *= parse_frac(number)
      store_value
      return true
    end
    
    # Sets the variable in the current expression cache and saves the value if
    # necessary.
    def update_variable(symbol)
      @cache[-1].variable = symbol
      store_value
      return true
    end
    
    # Resets the current expression cache to the parent cache, multiplied by a
    # given number.
    def reset_factor(factor = 1)
      @cache[-1] = @cache[-2] * factor
    end
    
    # Adds another level to the nesting stack.
    def add_nesting_level
      @cache << @cache[-1].clone
    end
    
    # Removes the top-most level of the nesting stack and resets the expression
    # cache.
    def remove_nesting_level
      @cache.pop
      reset_factor
    end
    
    # Stores the value currently present in the expression cache if all the
    # factors of the current term has been scanned.
    def store_value
      store_value!(@cache[-1].variable, @cache[-1].constant) if end_of_term?
    end
    
    # Stores the given value as the value of the given variable. If there is no
    # variable, the value will be subtracted from the current value of the
    # variable instead of added.
    def store_value!(variable, value)
      @variables[variable] ||= Rational(0)
      @variables[variable] += value * (variable == 1 ? -1 : 1)
      reset_factor
    end
    
    # Returns whether the scanner is currently at the end of a term or before a
    # closing parenthesis.
    def end_of_term?
      @scanner.check(/\)|[+-]|\z/)
    end
    
  end
end
