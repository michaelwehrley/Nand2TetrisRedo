require "byebug"

class Assembler
  attr_reader :file, :hack_file, :line_count

  def symbols
    @symbols ||= {
      "R0": "0",
      "R1": "1",
      "R2": "2",
      "R3": "3",
      "R4": "4",
      "R5": "5",
      "R6": "6",
      "R7": "7",
      "R8": "8",
      "R9": "9",
      "R10": "10",
      "R11": "11",
      "R12": "12",
      "R13": "13",
      "R14": "14",
      "R15": "15",
      "SCREEN": "16384",
      "KBD": "24576",
      "SP": "0",
      "LCL": "1",
      "ARG": "2",
      "THIS": "3",
      "THAT": "4"
    }
  end

  def labels
    @labels ||= {}
  end

  def initialize(file)
    @file = file
    @hack_file = File.open(File.join(File.dirname(__FILE__), "#{file}.hack"), "w")
    @line_count = 0
  end

  def translate
    set_labels
    File.open(File.join(File.dirname(__FILE__), "#{file}.asm")).each do |line|
      line = line.gsub(/\/{2}.*/, "").gsub(" ", "").strip
      next if white_space_or_comment?(line) || label(line)

      append(instruction(line))
    end
  end

  private

  def set_labels
    File.open(File.join(File.dirname(__FILE__), "#{file}.asm")).each do |line|
      line = line.gsub(/\/{2}.*/, "").gsub(" ", "").strip
      next if white_space_or_comment?(line)

      if label(line)
        labels[label(line)[1].to_sym] = @line_count.to_s
      else
        @line_count+=1
      end
    end
  end

  def label(line)
    line.match(/\((.*)\)/)
  end

  def append(content)
    File.write(hack_file, "#{content}\n", mode: "a")
  end

  def instruction(line)
    if !line.match(/^(\@)(.*)/).nil?
      line = substitute(line)

      AInstruction.new(line).decode
    else
      CInstruction.new(line).decode
    end
  end

  def substitute(line)
    symbols[line.match(/^(\@)(.*)/)[2].to_sym] ||
    labels[line.match(/^(\@)(.*)/)[2].to_sym] ||
    line
  end

  def white_space_or_comment?(line)
    line.match(/^\/\//) || line.length == 0
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
    @value ||= line.match(/^\@*(\d*)/)[1].to_i.to_s(2)
  end
end

class CInstruction < Instruction
  COMPUTATIONS = {
    "0": "101010",
    "1": "111111",
    "-1": "111010",
    "D": "001100",
    "A": "110000",
    "!D": "001101",
    "!A": "110001",
    "-D": "001111",
    "-A": "110011",
    "D+1": "011111",
    "A+1": "110111",
    "D-1": "001110",
    "A-1": "110010",
    "D+A": "000010",
    "D-A": "010011",
    "A-D": "000111",
    "D&A": "000000",
    "D|A": "010101",
  }.freeze

  DESTINATIONS = {
    "M": "001",
    "D": "010",
    "MD": "011",
    "A": "100",
    "AM": "101",
    "AD": "110",
    "AMD": "111"
  }.freeze

  JUMPS = {
    "JGT": "001",
    "JEQ": "010",
    "JGE": "011",
    "JLT": "100",
    "JNE": "101",
    "JLE": "110",
    "JMP": "111"
  }.freeze

  def decode
    "111#{memory_location}#{comp}#{destination}#{jump}"
  end

  private

  def memory_location
    line.match(/=.*(M)/).nil? ? 0 : 1
  end

  # right of `=` or left of `;`
  def comp
    comp = line.match(/=(.*)/) || line.match(/(.*);/)

    COMPUTATIONS[comp[1].gsub("M", "A").to_sym]
  rescue => e
    byebug
  end

  # left of `=` => destination STORING
  def destination
    return "000" unless dest = line.match(/(.*)=/)

    DESTINATIONS[dest[1].to_sym] || "000"
  end

  # right of `;` => jump (NOT STORING)
  def jump
    return "000" unless jump = line.match(/;(.*)/)

    JUMPS[jump[1].to_sym]
  end
end

# ARGV: argument vector
# ARGC: argument count
assembler = Assembler.new(ARGV.first)
assembler.translate
