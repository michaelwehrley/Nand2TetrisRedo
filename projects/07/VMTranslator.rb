require "byebug"

class VMTranslate
  attr_reader :assembly_file, :file, :line_count

  def initialize(file)
    @file = file    
    @assembly_file = File.open(File.join(File.dirname(__FILE__), "#{file}.asm"), "w")
    @line_count = 0
    # @ram_count = 16
  end

  def append(content)
    File.write(assembly_file, "#{content}\n", mode: "a")
  end

  def append_comment(content)
    append("// #{content}")
  end

  def increment_stack_pointer
    append("@SP\nM=M+1")
  end

  def decrement_stack_pointer
    append("@SP\nM=M-1")
  end

  def parse(line)
    /(^\w+)\s(\w+)\s(\d+$)/.match(line)
  end

  def white_space_or_comment?(line)
    line.length == 0 || line.match(/^\/\//)
  end

  TRANSLATIONS = {
    local: "LCL",
    argument: "ARG",
    this: "THIS",
    that: "THAT",
    temp: 5
  }.freeze

  def write
    File.open(File.join(File.dirname(__FILE__), "#{file}.vm")).each do |line|
      line = line.gsub(/\/{2}.*/, "").strip
      next if white_space_or_comment?(line)
      # ... remember
      # @SP get this address or const
      # D=M set it to D
      # A=M set the address register to the value of the M register which got set on @
      # M=D Set the memory of reg A to D

      # SIMPLY set RAM[3012] with 40
      # @40
      # D=A
      # @3012
      # M=D

      append_comment("#{line}")
      if line == "add"
        byebug
      elsif parse(line)[1] == "push" && parse(line)[2] == "constant"
        append("@#{parse(line)[3]}")
        append("D=A\n@SP\nA=M\nM=D")
        increment_stack_pointer
      elsif parse(line)[1] == "push" && %w(local argument that this temp).include?(parse(line)[2])
        append("@#{TRANSLATIONS[parse(line)[2].to_sym]}\nD=M")
        append("@#{parse(line)[3]}")
        append("A=D+A\nD=M") # go to the correct relative memory address and set pushed value on to SP and increment
        append("@SP\nA=M\nM=D")
        increment_stack_pointer
      elsif parse(line)[1] == "pop" && %w(local argument that this temp).include?(parse(line)[2])
        append("@#{TRANSLATIONS[parse(line)[2].to_sym]}\nD=M")
        append("@#{parse(line)[3]}")
        append("A=D+A\nD=M") # get current value on SP and pop to new segment
        decrement_stack_pointer
        append("@SP\nA=M\nM=D")
        # // pop that 2
        # @THAT
        # D=M
        # @2
        # // go to new address and get value to pop...
        # A=D+A
        # D=M
        # // decrement
        # @SP
        # M=M-1
        # // set new value
        # @SP
        # A=M
        # M=D
      else
        # byebug
      end
    end
  end
end

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslate.new(ARGV.first)
translator.write
