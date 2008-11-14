class PrecedenceTable

  # -1 is less than
  # 1 is greater than
  # 0 is erase
  # nil is end
  @@precedence_table = {}
  
  @@precedence_table['PlusOp'] = {}
  @@precedence_table['PlusOp']['StartSym'] = -1
  @@precedence_table['PlusOp']['PlusOp'] = 1
  @@precedence_table['PlusOp']['MinusOp'] = 1
  @@precedence_table['PlusOp']['MultiplyOp'] = 1
  @@precedence_table['PlusOp']['DivideOp'] = 1
  @@precedence_table['PlusOp']['NegOp'] = 1
  @@precedence_table['PlusOp']['LParen'] = -1
  @@precedence_table['PlusOp']['RParen'] = 1
  @@precedence_table['PlusOp']['AssignOp'] = -1
    
  @@precedence_table['MinusOp'] = {}
  @@precedence_table['MinusOp']['StartSym'] = -1
  @@precedence_table['MinusOp']['PlusOp'] = 1
  @@precedence_table['MinusOp']['MinusOp'] = 1
  @@precedence_table['MinusOp']['MultiplyOp'] = 1
  @@precedence_table['MinusOp']['DivideOp'] = 1
  @@precedence_table['MinusOp']['NegOp'] = 1
  @@precedence_table['MinusOp']['LParen'] = -1
  @@precedence_table['MinusOp']['RParen'] = 1
  @@precedence_table['MinusOp']['AssignOp'] = -1

  @@precedence_table['MultiplyOp'] = {}
  @@precedence_table['MultiplyOp']['StartSym'] = -1
  @@precedence_table['MultiplyOp']['PlusOp'] = -1
  @@precedence_table['MultiplyOp']['MinusOp'] = -1
  @@precedence_table['MultiplyOp']['MultiplyOp'] = 1
  @@precedence_table['MultiplyOp']['DivideOp'] = 1
  @@precedence_table['MultiplyOp']['NegOp'] = 1
  @@precedence_table['MultiplyOp']['LParen'] = -1
  @@precedence_table['MultiplyOp']['RParen'] = 1
  @@precedence_table['MultiplyOp']['AssignOp'] = -1  

  @@precedence_table['DivideOp'] = {}
  @@precedence_table['DivideOp']['StartSym'] = -1
  @@precedence_table['DivideOp']['PlusOp'] = -1
  @@precedence_table['DivideOp']['MinusOp'] = -1
  @@precedence_table['DivideOp']['MultiplyOp'] = 1
  @@precedence_table['DivideOp']['DivideOp'] = 1
  @@precedence_table['DivideOp']['NegOp'] = 1
  @@precedence_table['DivideOp']['LParen'] = -1
  @@precedence_table['DivideOp']['RParen'] = 1
  @@precedence_table['DivideOp']['AssignOp'] = -1
  
  @@precedence_table['NegOp'] = {}
  @@precedence_table['NegOp']['StartSym'] = -1
  @@precedence_table['NegOp']['PlusOp'] = -1
  @@precedence_table['NegOp']['MinusOp'] = -1
  @@precedence_table['NegOp']['MultiplyOp'] = -1
  @@precedence_table['NegOp']['DivideOp'] = -1
  @@precedence_table['NegOp']['NegOp'] = 0
  @@precedence_table['NegOp']['LParen'] = -1
  @@precedence_table['NegOp']['RParen'] = 1
  @@precedence_table['NegOp']['AssignOp'] = -1

  @@precedence_table['LParen'] = {}
  @@precedence_table['LParen']['StartSym'] = -1
  @@precedence_table['LParen']['PlusOp'] = -1
  @@precedence_table['LParen']['MinusOp'] = -1
  @@precedence_table['LParen']['MultiplyOp'] = -1
  @@precedence_table['LParen']['DivideOp'] = -1
  @@precedence_table['LParen']['NegOp'] = -1
  @@precedence_table['LParen']['LParen'] = -1
  @@precedence_table['LParen']['RParen'] = nil
  @@precedence_table['LParen']['AssignOp'] = -1

  @@precedence_table['RParen'] = {}
  @@precedence_table['RParen']['StartSym'] = 0
  @@precedence_table['RParen']['PlusOp'] = 1
  @@precedence_table['RParen']['MinusOp'] = 1
  @@precedence_table['RParen']['MultiplyOp'] = 1
  @@precedence_table['RParen']['DivideOp'] = 1
  @@precedence_table['RParen']['NegOp'] = 1
  @@precedence_table['RParen']['LParen'] = 0
  @@precedence_table['RParen']['RParen'] = 1
  @@precedence_table['RParen']['AssignOp'] = nil

  @@precedence_table['AssignOp'] = {}
  @@precedence_table['AssignOp']['StartSym'] = -1
  @@precedence_table['AssignOp']['PlusOp'] = 1
  @@precedence_table['AssignOp']['MinusOp'] = 1
  @@precedence_table['AssignOp']['MultiplyOp'] = 1
  @@precedence_table['AssignOp']['DivideOp'] = 1
  @@precedence_table['AssignOp']['NegOp'] = 1
  @@precedence_table['AssignOp']['LParen'] = nil
  @@precedence_table['AssignOp']['RParen'] = nil
  @@precedence_table['AssignOp']['AssignOp'] = nil
  
  @@precedence_table['SemiColon'] = {}
  @@precedence_table['SemiColon']['StartSym'] = nil
  @@precedence_table['SemiColon']['PlusOp'] = 1
  @@precedence_table['SemiColon']['MinusOp'] = 1
  @@precedence_table['SemiColon']['MultiplyOp'] = 1
  @@precedence_table['SemiColon']['DivideOp'] = 1
  @@precedence_table['SemiColon']['NegOp'] = 1
  @@precedence_table['SemiColon']['LParen'] = nil
  @@precedence_table['SemiColon']['RParen'] = 1
  @@precedence_table['SemiColon']['AssignOp'] = 1

  @@precedence_table['Comma'] = {}
  @@precedence_table['Comma']['StartSym'] = nil
  @@precedence_table['Comma']['PlusOp'] = 1
  @@precedence_table['Comma']['MinusOp'] = 1
  @@precedence_table['Comma']['MultiplyOp'] = 1
  @@precedence_table['Comma']['DivideOp'] = 1
  @@precedence_table['Comma']['NegOp'] = 1
  @@precedence_table['Comma']['LParen'] = nil
  @@precedence_table['Comma']['RParen'] = 1
  @@precedence_table['Comma']['AssignOp'] = 1
  
  def self.compare(lexeme, operator)
    return PrecedenceTable.new(lexeme, operator)
  end
      
  def less_than?
    return @precedence == -1
  end
  
  def greater_than?
    return @precedence == 1
  end
  
  def erase?
    return @precedence == 0
  end
  
  def end?
    return @precedence.nil?
  end
  
  private
  
  def initialize(lexeme, operator)
    # Don't want symbol table or int literal info
    lexeme = lexeme.split('_').first
  
    # we want to put the StartSym on the operator stack immediately
    if lexeme == 'StartSym'
      @precedence = -1
    else
      @precedence = @@precedence_table[lexeme][operator]
    end
  end
  
end
