# $ ruby vm_translator/VMTranslatorV2.rb source
# i.e., : $ ruby vm_translator/VMTranslatorV2.rb StackArithmetic/SimpleAdd/SimpleAdd.vm
# Test: CPUEmulator.sh

require_relative "bootstrap"

# ARGV: argument vector
# ARGC: argument count
VMTranslator::Bootstrap.call(ARGV.first)
