# $ ruby vm_translator/VMTranslatorV2.rb source

require_relative "bootstrap"

# ARGV: argument vector
# ARGC: argument count
translator = VMTranslator::Bootstrap.new(ARGV.first)
translator.call

