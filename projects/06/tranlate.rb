require "byebug"

class Assembler
  attr_reader :file, :hack_file

  def initialize(file)
    @file = file
    @hack_file = File.open(File.join(File.dirname(__FILE__), "#{file}.hack"), "w")
  end

  def translate
    set_symbols
    File.open(File.join(File.dirname(__FILE__), "#{file}.asm")).each do |line|
      next if white_space_or_comment?(line)

      append(instruction(line))
    end
  end

  private

  def set_symbols
  end

  def append(content)
    File.write(hack_file, "#{content}\n", mode: "a")
  end

  def instruction(line)
    if !line.match(/^.*(\@)/).nil?
      AInstruction.new(line).decode
    else
      CInstruction.new(line).decode
    end
  end

  def white_space_or_comment?(line)
    line.match(/^\s*$/) || line.match(/^\s*\/\//)
  end
end

class Instruction
  attr_reader :line

  def initialize(line)
    @line = line
  end
end

class AInstruction < Instruction
  def decode
    "0000000000000000".slice(0, 16 - value.length).concat(value)
  end

  private

  def value
    @value ||= line.match(/^.*\@(\d*)/)[1].to_i.to_s(2)
  end
end

class CInstruction < Instruction
  COMP_TABLE = {
    "0": "101010",
    "1": "111111",
    "-1": "111010",
    "D": "001100",
    "A": "110000",
    "M": "110000",
    "!D": "001101",
    "!A": "110001",
    "!M": "110001",
    "-D": "001111",
    "-A": "110011",
    "-M": "110011",
    "D+1": "011111",
    "A+1": "110111",
    "M+1": "110111",
    "D-1": "001110",
    "A-1": "110010",
    "M-1": "110010",
    "D+A": "000010",
    "D+M": "000010",
    "D-A": "010011",
    "D-M": "010011",
    "A-D": "000111",
    "M-D": "000111",
    "D&A": "000000",
    "D&M": "000000",
    "D|A": "010101",
    "D|M": "010101"
  }.freeze

  JUMP_TABLE = {
    "JGT": "001",
    "JEQ": "010",
    "JGE": "011",
    "JLT": "100",
    "JNE": "101",
    "JLE": "110",
    "JMP": "111"
  }.freeze

  def decode
    "111#{comp}#{destination}#{jump}"
  end

  private

  def comp
    "#{comp_a}#{comp_cs}"
  end

  def comp_a
    a? ? 0 : 1
  end

  def a?
    line.match(/=.*(M)/).nil?
  end

  def comp_cs
    return "000000" unless cs?

    COMP_TABLE[line.match(/=(.*)/)[1].strip!.to_sym]
  end

  def cs?
    !line.match(/=(.*)/).nil? # TODO consider comments..
  end

  def destination
    return "000" unless destination?

    "#{dest_field("A")}#{dest_field("D")}#{dest_field("M")}"
  end

  def destination?
    !line.match(/([ADM]*)=/).nil?
  end

  def dest_field(letter)
    line.match(/([ADM]*)=/)[1].include?(letter) ? "1" : "0"
  end

  def jump
    return "000" unless jump?

    JUMP_TABLE[line.match(/;(.*)/)[1].strip!.to_sym]
  end

  def jump?
    !line.match(/;(.*)/).nil? # TODO consider comments..
  end
end

SYMBOL_TABLE = {
  R0: 0,
  R1: 1,
  R2: 2,
  R3: 3,
  R4: 4,
  R5: 5,
  R6: 6,
  R7: 7,
  R8: 8,
  R9: 9,
  R10: 10,
  R11: 11,
  R12: 12,
  R13: 13,
  R14: 14,
  R15: 15,
  SCREEN: 16_384,
  KBD: 24_576,
  SP: 0,
  LCL: 1,
  ARG: 2,
  THIS: 3,
  THAT: 4
}

# ARGV: argument vector
# ARGC: argument count
assembler = Assembler.new(ARGV.first)
assembler.translate
