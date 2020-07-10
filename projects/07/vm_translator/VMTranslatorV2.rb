# $ ruby vm_translator/VMTranslatorV2.rb FunctionCalls/NestedCall/Sys

require_relative "bootstrap"

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslator::Bootstrap.new(ARGV.first)
translator.call

