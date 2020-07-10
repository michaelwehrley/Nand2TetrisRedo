require "byebug"
require_relative "code_writer"
require_relative "parser"

module VMTranslator
  class Bootstrap
    include CodeWriter
    include Parser
    attr_reader :asm_file, :vm_file

    def initialize(source)
      @vm_file = File.open("#{source}", "r")
      @asm_file = File.open("#{/([\/|\w]+)(\.*\w*)$/.match(source)[1]}.asm", "w")
    end

    private

    def directory?(file)
      /([\/|\w]+)(\.*\w*)$/.match(file)[2] == ""
    end
  end
end
