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

  def white_space_or_comment?(line)
    line.match(/^\/\//) || line.length == 0
  end

  def write
    File.open(File.join(File.dirname(__FILE__), "#{file}.vm")).each do |line|
      line = line.gsub(/\/{2}.*/, "").strip
      next if white_space_or_comment?(line)
      
      append("// #{line}")
    end
  end
end

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslate.new(ARGV.first)
translator.write
