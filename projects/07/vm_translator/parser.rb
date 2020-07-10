require "byebug"

module VMTranslator
  class Parser
    ARITHMETIC_COMMANDS = %w(add sub neg eq gt lt and or not).freeze

    attr_accessor :input, :options

    def initialize(input)
      @input = input
      @options = @input.strip.split(" ")
    end

    def parse
      return false unless command?
      {
        commandType: command_type,
        arg1: arg1,
        arg2: arg2
      }
    end

    private

    # Note: rubys `each` and `next` are analogous to `more_commands?` & `advance`
    # def more_commands?
    # end

    # def advance
    # end

    def command_type
      if arithmetic?
        "C_ARITHMETIC"
      else
        "C_#{arg0.upcase}"
      end
    end

    def arg1
      @arg1 ||= options[1]
    end

    def arg2
      @arg2 ||= options[2]
    end

    # bonus private methods

    def arg0
      @arg0 ||= options[0]
    end

    def arithmetic?
      ARITHMETIC_COMMANDS.include?(arg0)
    end

    def command?
      return true unless white_space? || comment? || line_break?
    end

    def white_space?
      input.length == 0
    end

    def comment?
      input.match(/^\/\//)
    end

    def line_break?
      input == "\r\n"
    end
  end
end

