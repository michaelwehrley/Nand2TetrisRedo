require "byebug"

module VMTranslator
  class CodeWriter
    TRANSLATIONS = {
      local: "LCL",
      argument: "ARG",
      this: "THIS",
      that: "THAT",
    }.freeze

    attr_accessor :asm_file,
                  :command_type,
                  :arg_0,
                  :arg_1,
                  :arg_2,
                  :line_count,
                  :relative_assembly_file_name,
                  :function_stack

    def initialize(asm_file:, line:, line_count:, function_stack:)
      @asm_file = asm_file
      @relative_assembly_file_name = /(\w+).asm$/.match(asm_file)[1]
      @command_type = line[:command_type]
      @arg_0 = line[:arg_0]
      @arg_1 = line[:arg_1]
      @arg_2 = line[:arg_2]
      @line_count = line_count
      @function_stack = function_stack
    end

    def write
      append_comment("#{arg_0} #{arg_1} #{arg_2}".gsub(/\s*$/, ""))
      return write_arithmetic if command_type == "C_ARITHMETIC"
      return write_push_pop if command_type == "C_POP" || command_type == "C_PUSH"
      return write_label if command_type == "C_LABEL"
      return write_goto if command_type == "C_GOTO"
      return write_if if command_type == "C_IF-GOTO"
      return write_call if command_type == "C_CALL"
      return write_return if command_type == "C_RETURN"
      return write_function if command_type == "C_FUNCTION"
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
      return write_push if command_type == "C_PUSH"
      return write_pop if command_type == "C_POP"

      raise "UnrecognizedCommand"
    end

    def write_push
      case arg_1
      when "constant"
        push_constant
      when "pointer"
        push_pointer
      when "static"
        push_static
      else
        push
      end
    end

    def write_pop
      case arg_1
      when "pointer"
        pop_pointer
      when "static"
        pop_static
      else
        pop
      end
    end

    def write_goto # Chapter 8
      append("@$#{arg_1}")
      append("0;JMP")
    end

    def write_if # Chapter 8
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      append("@$#{arg_1}")
      append("D;JNE")
    end

    def write_label # Chapter 8
      File.write(asm_file, "($#{arg_1})\n", mode: "a") # no '$'
    end

    def write_function # Chapter 8
      function_stack << arg_1
      File.write(asm_file, "(#{arg_1})\n", mode: "a")
      i = arg_2.to_i
      while i > 0
        i -= 1
        initialize_memory_segment_fn_arguments_to_zero
      end
    end

    def write_call # Chapter 8
      # TODO
    end

    def write_return # Chapter 8
      # Save caller's LCL
      append("@LCL")
      append("D=M")
      append_local_var("FRAME")
      append("M=D")

      # Put the `return-address` in a temporary variable.
      append("@5")
      append("D=A")
      append_local_var("FRAME")
      append("D=M-D")
      append_local_var("RET")
      append("M=D")

      # Reposition the `return` value for the caller -
      # (This is the return value for the caller)
      decrement_stack_pointer
      append("A=M")
      append("D=M")
      append("@ARG")
      append("A=M")
      append("M=D")
      # Restore SP of the caller
      append("@ARG")
      append("D=M+1")
      append("@SP")
      append("M=D")
      # Restore THAT
      append("@1")
      append("D=A")
      append_local_var("FRAME")
      append("D=M-D")
      append("A=D")
      append("D=M")
      append("@THAT")
      append("M=D")
      # Restore THIS
      append("@2")
      append("D=A")
      append_local_var("FRAME")
      append("D=M-D")
      append("A=D")
      append("D=M")
      append("@THIS")
      append("M=D")
      # Restore ARG
      append("@3")
      append("D=A")
      append_local_var("FRAME")
      append("D=M-D")
      append("A=D")
      append("D=M")
      append("@ARG")
      append("M=D")
      # Restore LCL
      append("@4")
      append("D=A")
      append_local_var("FRAME")
      append("D=M-D")
      append("A=D")
      append("D=M")
      append("@LCL")
      append("M=D")
      # goto @RET - Goto retun-address (in the caller's code)
      append_local_var("RET")
      append("A=M")
      append("0;JMP")

      function_stack.pop()
    end

    def append_local_var(variable_name)
      append("@#{function_stack.last}$#{variable_name}")
    end

    def initialize_memory_segment_fn_arguments_to_zero
      append("@0")
      append("D=A")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
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

    def pop_pointer
      decrement_stack_pointer
      append("@SP")
      append("A=M")
      append("D=M")
      append(translate(arg_2 == "0" ? "this" : "that"))
      append("M=D")
    end

    def pop_static
      decrement_stack_pointer
      append("@SP")
      append("A=M")
      append("D=M")
      append("@#{relative_assembly_file_name}.#{arg_2}")
      append("M=D")
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

    # Examples: push constant 10
    def push_constant
      append("@#{arg_2}")
      append("D=A")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def push_pointer
      append(translate(arg_2 == "0" ? "this" : "that"))
      append("D=M")
      append("@SP")
      append("A=M")
      append("M=D")
      increment_stack_pointer
    end

    def push_static
      append("@#{relative_assembly_file_name}.#{arg_2}")
      append("D=M")
      append("@SP")
      append("A=M")
      append("M=D")
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
