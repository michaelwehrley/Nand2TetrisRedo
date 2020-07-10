require "byebug"

class VMTranslate
  attr_reader :assembly_file, :src_file, :function_stack, :line_count, :output_file

  TRANSLATIONS = {
    local: "LCL",
    argument: "ARG",
    this: "THIS",
    that: "THAT",
    temp: nil
  }.freeze

  # TODAY: ruby VMTranslator.rb FunctionCalls/NestedCall/Sys FunctionCalls/NestedCall/NestedCall
  # TODO: ruby VMTranslator.rb --path=FunctionCalls/NestedCall --in=Sys --out=NestedCall
  def initialize(src_file, output_file = "")
    @src_file = src_file

    @line_count = 0
    # This either sets it or the file name is deduced, but the file name and is a match object
    @output_file = output_file || /\w+$/.match(src_file).to_s
    @assembly_file = File.open(File.join(File.dirname(__FILE__), "#{output_file}.asm"), "w")
    @function_stack = []
  end

  def write
    File.open(File.join(File.dirname(__FILE__), "#{src_file}.vm")).each do |line|
      line = line.gsub(/\/{2}.*/, "").strip
      next if white_space_or_comment?(line)
      append_comment(line)
      action = parse(line)[1]
      segment = parse(line)[2]
      value = parse(line)[3]
      register = register_name(segment)

      # TODO: turn into a case statement ;-)
      if action == "add"
        add("+")
      elsif action == "sub"
        add("-")
      elsif action == "eq"
        equal
      elsif action == "lt"
        less_than
      elsif action == "gt"
        greater_than
      elsif action == "neg"
        neg
      elsif action == "and"
        _and
      elsif action == "or"
        _or
      elsif action == "not"
        _not
      elsif action == "push" && segment == "constant"
        append("@#{value}")
        push_constant
      elsif action == "push" && segment?(segment)
        push(register, value, segment == "temp")
      elsif action == "push" && segment == "static"
        push_static(value)
      elsif action == "push" && segment == "pointer"
        value == "0" ? push_pointer("THIS") : push_pointer("THAT")
      elsif action == "pop" && segment?(segment)
        pop(register, value, segment == "temp")
      elsif action == "pop" && segment == "static"
        pop_static(value)
      elsif action == "pop" && segment == "pointer"
        pop_pointer(value)
      elsif action == "label"
        generate_label(assembly_file: assembly_file, segment: segment)
      elsif action == "if-goto"
        decrement_stack_pointer
        append("A=M")
        append("D=M")
        append("@#{relative_label(segment)}")
        append("D;JNE")
      elsif action == "goto"
        append("@#{relative_label(segment)}")
        append("0;JMP")
      elsif action == "function"
        function_stack << segment
        File.write(assembly_file, "(#{segment})\n", mode: "a")
        i = value.to_i
        while i > 0
          i -= 1
          initialize_to_zero
        end
      elsif action == "return"
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
      elsif action == "call"
        return_address = "#{relative_label(segment)}$return-address"
        call(segment, value.to_i, return_address)
      else
        raise "UnrecognizedCommand"
      end
    rescue => exception
      byebug
    end
  end

  private

  def append_local_var(variable_name)
    # TODO: add file path
    append("@#{current_function_stack}$#{variable_name}")
  end

  def call(segment, value, return_address)
    # storing future line return address here.
    append("@#{line_count + 47}")
    append("D=A")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
    # append("@#{return_address}")

    # push LCL of calling fn
    push_pointer("LCL")
    # push ARG of calling fn
    push_pointer("ARG")
    # push THIS of calling fn
    push_pointer("THIS")
    # push THAT of calling fn
    push_pointer("THAT")
    append("@SP")
    append("D=M")
    # reposition ARG (n = number of args)
    append("@#{value + 5}")
    append("D=D-A")
    append("@ARG")
    append("M=D")
    # reposition LCL
    append("@SP")
    append("D=M")
    append("@LCL")
    append("M=D")
    # transfer control `goto f`
    append("@#{segment}")
    append("0;JMP")
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
    append("@#{line_count + 7}")
    append("D;JNE") # ...
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
    append("@#{line_count + 7}")
    append("D;JGE") # ...
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
    append("@#{line_count + 7}")
    append("D;JLE") # ...
    append("@0")
    append("D=A-1")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def neg
    decrement_stack_pointer
    append("A=M")
    append("M=-M")
    increment_stack_pointer  
  end

  def _and
    decrement_stack_pointer
    append("A=M")
    append("D=M")
    decrement_stack_pointer
    append("A=M")
    append("M=M&D")
    increment_stack_pointer
  end

  def _or
    decrement_stack_pointer
    append("A=M")
    append("D=M")
    decrement_stack_pointer
    append("A=M")
    append("M=M|D")
    increment_stack_pointer
  end

  def _not
    decrement_stack_pointer
    append("A=M")
    append("M=!M")
    increment_stack_pointer  
  end

  def add(operation)
    decrement_stack_pointer
    append("A=M")
    append("D=M")
    decrement_stack_pointer
    append("A=M")
    append("M=M#{operation}D")
    increment_stack_pointer
  end

  def pop(register, target, is_temp)
    decrement_stack_pointer
    # get value that is current on top of stack
    append("@SP")
    append("A=M")
    append("D=M")
    append("@stackValue")
    append("M=D") # storing value to be popped in temp

    # get relative address
    append(is_temp ? "@5" : register)
    append(is_temp ? "D=A" : "D=M")
    append("@#{target}")
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

  def pop_static(target)
    decrement_stack_pointer
    append("@SP")
    append("A=M")
    append("D=M")
    append("@#{output_file}.#{target}")
    append("M=D")
  end

  def pop_pointer(value)
    decrement_stack_pointer
    append("@SP")
    append("A=M")
    append("D=M")
    value == "0" ? append("@THIS") : append("@THAT")
    append("M=D")
  end

  def push_pointer(value)
    append("@#{value}")
    append("D=M")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def push_constant # TODO: pass in constant!
    append("D=A")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def push(register, target, is_temp)
    append(is_temp ? "@5" : register)
    append(is_temp ? "D=A" : "D=M")
    append("@#{target}")
    append("A=D+A")
    append("D=M")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def push_static(target)
    append("@#{output_file}.#{target}")
    append("D=M")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def append(content)
    @line_count += 1
    File.write(assembly_file, "#{content}\n", mode: "a")
  end

  def append_comment(content)
    File.write(assembly_file, "// #{content}\n", mode: "a")
  end

  def decrement_stack_pointer
    append("@SP")
    append("M=M-1")
  end

  def increment_stack_pointer
    append("@SP")
    append("M=M+1")
  end

  def initialize_to_zero
    append("@0")
    append("D=A")
    append("@SP")
    append("A=M")
    append("M=D")
    increment_stack_pointer
  end

  def parse(line)
    /(^\w+)\s(\w+)\s(\d+$)/.match(line) ||
      /(^\w+$)/.match(line) ||
      /(^label|if-goto|goto)\s(\S*$)/.match(line) ||
      /(^function)\s+(\w+\.\w+)\s+(\w+)/.match(line) ||
      /(call)\s+(Sys.\w+)\s+(\d+)/.match(line)
  end

  def white_space_or_comment?(line)
    line.length == 0 || line.match(/^\/\//)
  end

  def register_name(segment)
    return unless segment

    "@#{TRANSLATIONS[segment.to_sym]}"
  end

  def segment?(segment)
    return false unless segment

    TRANSLATIONS.keys.include?(segment.to_sym)
  end

  def generate_label(assembly_file:, segment:)
    File.write(assembly_file, "(#{relative_label(segment)})\n", mode: "a")
  end

  def relative_label(segment)
    "#{current_function_stack}$#{segment}"
  end

  def current_function_stack
    function_stack.last
  end
end

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslate.new(ARGV[0], ARGV[1])
translator.write
