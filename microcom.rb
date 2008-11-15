# Chris Durtschi
# CS 4820
# David Hart
# MicroCom - Main Driver

require 'microcom/lexical_scanner'
require 'microcom/syntactical_parser'
require 'microcom/semantical_phase'
require 'microcom/precedence_table'
require 'microcom/code_generator'

puts "Enter .mic file, with or without extension:"
path = gets.chomp

mic_path = path
mic_path += '.mic' if !mic_path.match(/^\w+\.mic$/)
lis_path = mic_path.gsub('.mic', '.lis')
lex_path = mic_path.gsub('.mic', '.lex')
sem_path = mic_path.gsub('.mic', '.sem')
tas_path = mic_path.gsub('.mic', '.tas')

if (!File.exist?(mic_path))
  puts "File does not exist: #{mic_path}"
  exit
end

symbol_table = []
int_literal_table = []

lexemes = []
atoms = []

scanner = LexicalScanner.new(mic_path, lex_path, lis_path, lexemes,
    symbol_table, int_literal_table)

if scanner.scan
  parser = SyntacticalParser.new(lex_path, lis_path, lexemes)
  if parser.parse
    semantic = SemanticalPhase.new(sem_path, lis_path, lexemes, atoms,
        symbol_table, int_literal_table)
    semantic.run
    
    generator = CodeGenerator.new(lis_path, tas_path, atoms, symbol_table, 
        int_literal_table)
    generator.generate
  end
end