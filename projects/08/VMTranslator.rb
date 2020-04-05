require "byebug"

class VMTranslate
  attr_reader :assembly_file, :file, :line_count, :relative_assembly_file_name

  TRANSLATIONS = {
    local: "LCL",
    argument: "ARG",
    this: "THIS",
    that: "THAT",
    temp: nil
  }.freeze

  def initialize(file)
    @file = file
    @line_count = 0
    @relative_assembly_file_name = /\w+$/.match(file)
    @assembly_file = File.open(File.join(File.dirname(__FILE__), "#{file}.asm"), "w")
  end

  def write
    File.open(File.join(File.dirname(__FILE__), "#{file}.vm")).each do |line|
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
        push_pointer(value)
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
        append("@#{segment}")
        append("D;JNE")
      elsif action == "goto"
        # decrement_stack_pointer
        # append("A=M")
        append("@#{segment}")
        append("0;JMP")
      elsif action == "function"
        generate_label(assembly_file: assembly_file, segment: segment)
        i = value.to_i
        while i >= 1 
          append("@#{value}")
          push_constant
          i = i - 1            
        end
        # FRAME is a temporary variable: `FRAME = LCL`
        append("@LCL")
        append("M=A")
        append("D=M")
        append("@FRAME")
        append("M=D")
        # Put the return=address in a temporary variable: `RET *(FRAME-5)`
        append("@5")
        append("D=A")
        append("@FRAME")
        append("A=M")
        append("D=M-D")
        append("@RET")
        append("M=D")
        # Reposition the return value for the caller: `*ARG = pop()`
        append("@SP")
        append("A=M")
        append("D=M")
        append("@ARG")
        append("A=M")
        append("M=D")
      elsif action == "return"
        byebug
        # TODO
      else
        byebug
        raise "UnrecognizedCommand"
      end
    rescue => exception
      byebug
    end
  end

  private

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
    append("@#{relative_assembly_file_name}.#{target}")
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
    value == "0" ? append("@THIS") : append("@THAT")
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
    append("@#{relative_assembly_file_name}.#{target}")
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

  def parse(line)
    /(^\w+)\s(\w+)\s(\d+$)/.match(line) ||
      /(^\w+$)/.match(line) ||
      /(^label|if-goto|goto)\s(\S*$)/.match(line) ||
      /(^function)\s+(\w+\.\w+)\s+(\w+)/.match(line)
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
    # TODO (functionName$label)
    File.write(assembly_file, "(#{segment})\n", mode: "a")
  end
end

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslate.new(ARGV.first)
translator.write
