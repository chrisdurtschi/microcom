class Lexeme

  @@operators = ['AssignOp', 'PlusOp', 'MinusOp', 
                 'NegOp', 'MultiplyOp', 'DivideOp',
                 'LParen', 'RParen', 'Colon', 'SemiColon']
  @@operands = ['Id', 'IntLiteral']
  @@lexemes = @@operators + @@operands
  
  def create(lexeme)
      raise "Not a lexeme symbol: #{lexeme}" if !@@lexemes.member?(lexeme)
      Token.new(lexeme)
  end
  
  private
  
  def initialize(lexeme)
      case lexeme
          when @@lexemes[0]
      end
  end

end
