class SemanticalPhase

  @@operators = ['StartSym', 'PlusOp', 'MinusOp', 'MultiplyOp', 'DivideOp',
                 'NegOp', 'LParen', 'RParen', 'AssignOp', 'SemiColon', 'Comma']

  def initialize(lis_path, lex_path, sem_path, symbol_table)
    @atoms = []
    @lexemes = []
    @symbol_table = symbol_table
    
    @lis_path = lis_path
    @lex_path = lex_path
    @sem_path = sem_path
    
    load_lexemes
  end
  
  # push all the lexemes for a single line statement
  # onto the @lexemes stack
  def load_lexemes
    statement = []
    
    File.open(@lex_path, "r") do |file|
      while line = file.gets
        line.chomp!
            
        if ['@', 'BeginSym', 'EndSym', 'EofSym'].member?(line)
          if !statement.empty?
            @lexemes.push(statement)
            statement = []
          end
        else
          statement.push(line)
        end
      end
    end
  end
  
  def run
    @lexemes.each do |line|
      evaluate_expression(line)
    end
    
    write_sem
  end
  
  # evaluate_expression will return either nil,
  # or the name of a variable
  def evaluate_expression(lexemes)
    lexeme = lexemes.first.split('_').first
    
    return if !lexeme
    
    if (lexeme == 'ReadSym')
      return read_expression(lexemes)
    elsif (lexeme == 'WriteSym')
      return write_expression(lexemes)
    elsif (lexeme == 'Id')
      return id_expression(lexemes)
    else
    	return polishize(lexemes)  
    end        
  end
  
  def read_expression(lexemes)
    lexemes.each do |lexeme|
      lexeme, id = lexeme.split('_')
      if (lexeme == 'Id' || lexeme == 'IntLiteral')
        atom = ['ReadSym', @symbol_table[id.to_i]]
        @atoms.push(atom)
      end
    end
    
    return nil
  end
  
  def write_expression(lexemes)
    statement = []
    
    lexemes.reverse!
    
    # Get rid of WriteSym
    lexemes.pop
    
    # Get rid of LParen
    lexemes.pop
    
    while lexeme = lexemes.pop
      break if lexeme == 'SemiColon'
      
      if lexeme == 'Comma' || lexeme == 'RParen'
        atom = ['WriteSym', evaluate_expression(statement)]
        @atoms.push(atom)
        statement = []
      else
        statement.push(lexeme)
      end
    end
   
    return nil
  end
  
  def id_expression(lexemes)
    return lexemes.first if lexemes.length <= 1
    return polishize(lexemes)
  end
  
  # This method will order a statement
  # into Reverse Polish Notation
  def polishize(lexemes)
    operators = []
    operands = []
    
    lexemes.reverse!
    lexemes.push('StartSym')
    
    while lexeme = lexemes.pop
      if @@operators.member?(lexeme)
        compare_precedence(lexeme, operators, operands)
      else
        operands.push(lexeme)
      end
    end

    return atomize(operands)
  end
  
  def compare_precedence(lexeme, operators, operands)
    precedence = PrecedenceTable.compare(lexeme, operators.last)
    
    if precedence.less_than?
      operators.push(lexeme)
    elsif precedence.greater_than?
      operator = operators.pop
      operands.push(operator)
      compare_precedence(lexeme, operators, operands)
    elsif precedence.erase?
      operators.pop
    end
  end
  
  # This method takes a collection of lexemes
  # in Reverse Polish Notation, and creates atoms
  def atomize(lexemes)
    temp_num = 0
    
    while !lexemes.empty?
      lexemes.each_index do |i|
        lexeme = lexemes[i]
        if @@operators.member?(lexeme)
          if lexeme == 'AssignOp'
            lexeme = lexemes.delete_at(i)
            operand = lexemes.delete_at(i - 1)
            id = lexemes.delete_at(i - 2)
            atom = [lexeme, id, operand]
            @atoms.push(atom)
            break
          elsif lexeme == 'NegOp'
            temp = "Temp#{temp_num}"
            temp_num = temp_num.next

            lexemes[i] = temp
            operand = lexemes.delete_at(i - 1)
            atom = ['MinusOp', temp, 'IntLiteral_0', operand]
            @atoms.push(atom)
            break
          else
            temp = "Temp#{temp_num}"
            temp_num = temp_num.next
            
            lexemes[i] = temp
            operand2 = lexemes.delete_at(i - 1)
            operand1 = lexemes.delete_at(i - 2)
            atom = [lexeme, temp, operand1, operand2]
            
            puts atom.join(', ')
            
            @atoms.push(atom)
            break
          end
        end
      end
    end
    
    # return the last Identifier
    return @atoms.last[1]
  end
  
  def write_sem
  	File.open(@sem_path, "w") do |sem|
  		@atoms.each {|atom| sem.puts(atom.join(','))}
  	end
	end
  
end
