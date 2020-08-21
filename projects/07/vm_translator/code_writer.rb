require "byebug"

module VMTranslator
  class CodeWriter
    attr_accessor :asm_file, :command_type, :arg_0, :arg_1, :arg_2, :line_count

    def initialize(asm_file:, line:, line_count:)
      @asm_file = asm_file
      @command_type = line[:command_type]
      @arg_0 = line[:arg_0]
      @arg_1 = line[:arg_1]
      @arg_2 = line[:arg_2]
      @line_count = line_count
    end

    def write
      append_comment("#{arg_0} #{arg_1} #{arg_2}".gsub(/\s*$/, ""))
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
      when "eq"
        equal
      when "gt"
        greater_than
      when "lt"
        less_than
      when "neg"
        negate
      when "sub"
        subtract
      when "and"
        intersection
      when "or"
        union
      when "not"
        opposite
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
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("M=M+D")
      increment_stack_pointer
    end

    def subtract
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("M=M-D")
      increment_stack_pointer
    end

    def push
      append("@#{arg_2}")
      append("D=A")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def pop
    end

    # -1 is TRUE (1111111111111111)
    # 0 is FALSE
    def equal
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("D=D-M")
      append("M=0") # set to not equal by default: `false`, i.e., 0000000000000000
      append("@#{@line_count + 7}")
      append("D;JNE") # ...
      append("@0")
      append("D=A-1")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def greater_than
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("D=M-D")
      append("M=0") # set to not equal by default: `false`, i.e., 0000000000000000
      append("@#{@line_count + 7}")
      append("D;JLE") # ...
      append("@0")
      append("D=A-1")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def less_than
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("D=M-D")
      append("M=0") # set to not equal by default: `false`, i.e., 0000000000000000
      append("@#{@line_count + 7}")
      append("D;JGE") # ...
      append("@0")
      append("D=A-1")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def negate
      decrement_stack_pointer
      append("A=M")
      append("M=-M")
      increment_stack_pointer
    end

    def decrement_stack_pointer
      append("@SP")
      append("M=M-1")
    end

    def increment_stack_pointer
      append("@SP")
      append("M=M+1")
    end

    def intersection
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("M=M&D")
      increment_stack_pointer
    end

    def union
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      decrement_stack_pointer
      append("A=M")
      append("M=M|D")
      increment_stack_pointer
    end

    def opposite
      decrement_stack_pointer
      append("A=M")
      append("M=!M")
      increment_stack_pointer
    end

    def append(value)
      @line_count += 1
      File.write(asm_file, "#{value}\n", mode: "a")
    end

    def append_comment(value)
      File.write(asm_file, "// #{value}\n", mode: "a")
    end
  end
end
