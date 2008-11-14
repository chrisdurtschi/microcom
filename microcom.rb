# Chris Durtschi
# CS 4820
# David Hart
# MicroCom - Main Driver

require 'microcom/lexical_scanner'
require 'microcom/syntactical_scanner'
require 'microcom/semantical_phase'
require 'microcom/precedence_table'

puts "Enter .mic file, with or without extension:"
path = gets.chomp

mic_path = path
mic_path += '.mic' if !mic_path.match(/^\w+\.mic$/)
lex_path = mic_path.gsub('.mic', '.lex')
lis_path = mic_path.gsub('.mic', '.lis')
sem_path = mic_path.gsub('.mic', '.sem')

if (!File.exist?(mic_path))
  puts "File does not exist: #{mic_path}"
  exit
end

symbol_table = []
int_literal_table = []

scanner = LexicalScanner.new(mic_path, lex_path, lis_path, symbol_table)

if scanner.scan
  scanner = SyntacticalScanner.new(lex_path, lis_path)
  if scanner.scan
    semantic = SemanticalPhase.new(lis_path, lex_path, sem_path,
        symbol_table, int_literal_table)
    semantic.run
  end
end