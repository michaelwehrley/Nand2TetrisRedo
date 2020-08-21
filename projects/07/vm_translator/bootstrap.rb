require "byebug"
require_relative "code_writer"
require_relative "parser"

module VMTranslator
  class Bootstrap
    attr_accessor :asm_file, :vm_file

    def initialize(source)
      @vm_file = File.open("#{source}", "r") # Xxx.vm or directory
      @asm_file = "#{/([\/|\w]+)(\.*\w*)$/.match(source)[1]}.asm"
      reset_output
    end

    def call
      vm_file.each do |line|
        next unless parsed_line = Parser.new(line).parse

        CodeWriter.new(asm_file: asm_file, line: parsed_line).write
      end
    end

    private

    def directory?(file)
      /([\/|\w]+)(\.*\w*)$/.match(file)[2] == ""
    end

    def reset_output
      File.open(asm_file, "w")
    end
  end
end