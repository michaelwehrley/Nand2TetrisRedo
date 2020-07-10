require "byebug"
require_relative "code_writer"
require_relative "parser"

module VMTranslator
  class Bootstrap
    include CodeWriter
    include Parser
    attr_reader :asm_file, :vm_file

    def initialize(file)
      path = File.join(File.expand_path("../../", __FILE__), file)
      @vm_file = File.open("#{path}.vm", "r")
      @asm_file = File.open("#{path}.asm", "w")
    end
  end
end
