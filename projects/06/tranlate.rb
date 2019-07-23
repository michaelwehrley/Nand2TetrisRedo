require "byebug"
class Assembler
  attr_reader :file, :hack_file

  def initialize(file)
    @file = file
    @hack_file = File.open(File.join(File.dirname(__FILE__), "#{file}.hack"), "w")
  end

  def translate
    set_symbols
    # Set n to 16
    # Scan the entire program again; for each instruction
    #    * If the instruction is `@symbol`, look up the symbol in the symbol table
    #    * If not found
    #      * Add (symbole, `n`) to the symbol table
    #      * Use `n` to complete the instructions's translation
    #      * `n++` Nex tline
    #   * If the instruction is a C-instruction, complete the instruciton's translation
    #   * Write the translated instruciton to the output file.
    File.open(File.join(File.dirname(__FILE__), "#{file}.asm")).each do |line|
      next if white_space_or_comment?(line)

      append(instruction(line))
    end
  end

  private

  def set_symbols
    # scan entire program
    # Add the pair (xxx, address) to the symbol table,
    # where `address` is the number of the sintruciotn following(xxx)
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
    "0000000000000000".slice(0, 15 - value.length).concat(value)
  end

  private

  def value
    @value ||= line.match(/^.*\@(\d*)/)[1].to_i.to_s(2)
  end
end

class CInstruction < Instruction
  def decode
    "111#{comp}#{dest}#{jump}"
  end

  private

  def comp_a
    a? ? 0 : 1
  end

  def comp_cs
    return unless cs?

    COMP_TABLE[line.match(/=(.*)/)[1].strip!.to_sym]
  end

  def comp
    "#{comp_a}#{comp_cs}"
  end

  def a?
    line.match(/=.*(M)/).nil?
  end

  def cs?
    !line.match(/=(.*)/).nil? # TODO for comments..
  end

  def dest
    return "000" unless dest?
    "#{destination_a}#{destination_d}#{destination_m}"
  end

  def dest?
  end

  def jump
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

# 1. Ignore white space and comments
# 1. Instructions
#   1. A-Instruction: @valueInBinary == 0 000001010101...
#       ex: @value == @20
#   1. C-Instruction: dest = comp;jump
#       ex: 111ac1c2c3c4c5c6d1d2d3j1j2j3
# 1. Symbols - later
#   1. Pre-defined...


# if 1
#   CInstruction.translate()
# else
#   A-Instruction.translate()
# end

# ARGV: argument vector
# ARGC: argument count
assembler = Assembler.new(ARGV.first)
assembler.translate
