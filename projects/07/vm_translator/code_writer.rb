require "byebug"

module VMTranslator
  class CodeWriter
    TRANSLATIONS = {
      local: "LCL",
      argument: "ARG",
      this: "THIS",
      that: "THAT",
    }.freeze

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
      return push_pointer if arg_0 == "push" && arg_1 == "pointer"
      return push_constant if arg_0 == "push" && arg_1 == "constant"
      return push if arg_0 == "push"
      return pop_pointer if arg_0 == "pop" && arg_1 == "pointer"
      return pop if arg_0 == "pop"
    end

    def close
    end

    private

    def pop_pointer
      decrement_stack_pointer
      append("@SP")
      append("A=M")
      append("D=M")
      append(translate(arg_2 == "0" ? "this" : "that"))
      append("M=D")
    end

    def push_pointer
      append(translate(arg_2 == "0" ? "this" : "that"))
      append("D=M")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

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

    # Examples: push constant 10
    def push_constant
      append("@#{arg_2}")
      append("D=A")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def push
      # Examples: push local 0, push that 5, push argument 1, push this 6, push temp 6
      append(arg_1 == "temp" ? "@5" : translate(arg_1))
      append(arg_1 == "temp" ? "D=A" : "D=M")
      append("@#{arg_2}")
      append("A=D+A")
      append("D=M")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def pop
      # Examples: `pop local 0`, `pop argument 2`, `pop this 6`, `pop that 5`, `pop temp 6`
      decrement_stack_pointer
      # get value that is current on top of stack
      append("@SP")
      append("A=M")
      append("D=M")
      append("@stackValue")
      append("M=D") # storing value to be popped in temp

      # get relative address
      append(arg_1 == "temp" ? "@5" : translate(arg_1))
      append(arg_1 == "temp" ? "D=A" : "D=M")
      append("@#{arg_2}")
      append("D=D+A")
      append("@targetLocation")
      append("M=D") # store relative address in target address

      # put stack value in target location
      append("@stackValue")
      append("D=M")
      append("@targetLocation")
      append("A=M")
      append("M=D")
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

    def translate(arg)
      "@#{TRANSLATIONS[arg.to_sym]}"
    end
  end
end
