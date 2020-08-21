require "byebug"

module VMTranslator
  class CodeWriter
    attr_accessor :asm_file, :command_type, :arg_0, :arg_1, :arg_2

    def initialize(asm_file:, line:)
      @asm_file = asm_file
      @command_type = line[:command_type]
      @arg_0 = line[:arg_0]
      @arg_1 = line[:arg_1]
      @arg_2 = line[:arg_2]
    end

    def write
      if command_type == "C_ARITHMETIC"
        write_arithmetic
      else
        write_push_pop
      end
    end

    def set_file_name(file_name)
    end

    def write_arithmetic
      case arg_0
      when "add"
        add
      end
    end

    def write_push_pop
      return push if arg_0 == "push"
      return pop if arg_0 == "pop"
    end

    def close
    end

    private

    def add
      append_comment("add")
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("M=M+D")
      increment_stack_pointer
    end

    def push
      append_comment("push #{arg_1} #{arg_2}")
      append("@#{arg_2}")
      append("D=A")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def pop
    end

    def decrement_stack_pointer
      append("@SP")
      append("M=M-1")
    end

    def increment_stack_pointer
      append("@SP")
      append("M=M+1")
    end

    def append(value)
      # @line_count += 1
      File.write(asm_file, "#{value}\n", mode: "a")
    end

    def append_comment(value)
      append("// #{value}")
    end
  end
end
