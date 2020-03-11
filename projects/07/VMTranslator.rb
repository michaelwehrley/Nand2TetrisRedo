require "byebug"

class VMTranslate
  attr_reader :assembly_file, :file, :relative_assembly_file_name

  TRANSLATIONS = {
    local: "LCL",
    argument: "ARG",
    this: "THIS",
    that: "THAT",
    temp: nil
  }.freeze

  def initialize(file)
    @file = file
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

      if action == "add"
        add("+")
      elsif action == "sub"
        add("-")
      elsif action == "push" && segment == "constant"
        append("@#{value}")
        push_constant
      elsif action == "push" && segment?(segment)
        push(register, value, segment == "temp")
      elsif action == "push" && segment == "static"
        push_static(value)
      elsif action == "pop" && segment?(segment)
        pop(register, value, segment == "temp")
      elsif action == "pop" && segment == "static"
        pop_static(value)
      else
        byebug
      end
    end
  end

  private

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

  def push_constant
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
    File.write(assembly_file, "#{content}\n", mode: "a")
  end

  def append_comment(content)
    append("// #{content}")
  end

  def decrement_stack_pointer
    append("@SP\nM=M-1")
  end

  def increment_stack_pointer
    append("@SP\nM=M+1")
  end

  def parse(line)
    /(^\w+)\s(\w+)\s(\d+$)/.match(line) || /(^\w+$)/.match(line)
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
end

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslate.new(ARGV.first)
translator.write
