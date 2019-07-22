class Assembler
  DEFAULT_WORD = "0000000000000000".freeze

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

  def a_instruction?(line)
    !line.match(/^.*(\@)/).nil?
  end

  def append(content)
    File.write(hack_file, "#{content}\n", mode: "a")
  end

  def instruction(line)
    if a_instruction?(line)
      decode_to_16_bits(line)
    else

    end
  end

  def decode_to_16_bits(line)
    base_2 = line.match(/^.*\@(\d*)/)[1].to_i.to_s(2)
    DEFAULT_WORD.slice(0, 15 - base_2.length).concat(base_2)
  end

  def white_space_or_comment?(line)
    line.match(/^\s*$/) || line.match(/^\s*\/\//)
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
  SCREEN: 16384,
  KBD: 24576,
  SP: 0,
  LCL: 1,
  ARG: 2,
  THIS: 3,
  THAT: 4
}

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
