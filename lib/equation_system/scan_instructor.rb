require 'strscan'

class EquationSystem
  class ScanInstructor
    attr_reader :scanner
    
    def self.scan(subject, &block)
      instructor = ScanInstructor.new(subject)
      block.call(instructor)
      instructor.scan!
    end
    
    def initialize(subject)
      @scanner = StringScanner.new(subject)
      @tests = []
      @skips = []
    end
    
    # Instructs the scanner to skip the given pattern if found in the string.
    def skip(pattern)
      @skips << pattern
    end
    
    # Instructs the scanner to stop at the given pattern and execute the given block before proceeding.
    def at(pattern, &block)
      @tests << [pattern, block]
    end
    
    # Scans the string for the specified patterns.
    def scan!
      find_match until @scanner.eos?
    end
    
    private
    # Finds the next pattern match and returns the result of the associated block.
    # Raises an error if no patterns match.
    def find_match
      @skips.each { |pattern| @scanner.skip(pattern) }
      @tests.each do |pattern, block|
        if result = @scanner.scan(pattern)
          return (block.arity.zero? ? block.call : block.call(result))
        end
      end
      raise "Error: Unregocnized character (#{@scanner.peek(1).inspect})."
    end
  end
end
