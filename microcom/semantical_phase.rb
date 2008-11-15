class SemanticalPhase

  @@operators = ['StartSym', 'PlusOp', 'MinusOp', 'MultiplyOp', 'DivideOp',
                 'NegOp', 'LParen', 'RParen', 'AssignOp', 'SemiColon', 'Comma']

  def initialize(sem_path, lis_path, lexemes, atoms, 
      symbol_table, int_literal_table)
    @lis_path = lis_path
    @sem_path = sem_path

    @lexemes = []
    @atoms = atoms

    @symbol_table = symbol_table
    @int_literal_table = int_literal_table
    
    divide_lexemes_into_statements(lexemes)
  end
  
  def run
    @lexemes.each do |line|
      evaluate_expression(line)
    end
    
    message = 'Semantical phase successful - .sem file generated'
    write_sem
    write_lis(message)
    puts(message)
  end
  
  private
  
  # push all the lexemes for a single line statement
  # onto the @lexemes stack
  def divide_lexemes_into_statements(lexemes)
    statement = []
    
    lexemes.each do |lexeme|
      if ['@', 'BeginSym', 'EndSym', 'EofSym'].member?(lexeme)
        if !statement.empty?
          @lexemes.push(statement)
          statement = []
        end
      else
        statement.push(lexeme)
      end
    end
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
      first = lexeme.split('_').first
      if (first == 'Id' || first == 'IntLiteral')
        atom = ['ReadSym', get_lexeme_value(lexeme)]
        @atoms.push(atom)
      end
    end
    
    return nil
  end
  
  def write_expression(lexemes)
    statement = []
    
    # Reverse lexemes so we can pop off the
    # lexemes from the beginning of the string.
    lexemes.reverse!
    
    # Get rid of WriteSym
    lexemes.pop
    
    # Get rid of LParen
    lexemes.pop
    
    while lexeme = lexemes.pop
      statement.push(lexeme) if lexeme != 'SemiColon'
      
      if lexeme == 'Comma' || lexeme == 'SemiColon'
        atom = ['WriteSym', evaluate_expression(statement)]
        @atoms.push(atom)
        statement = []
      end
    end
   
    return nil
  end
  
  # If this expression is just a single Id,
  # possibly followed by a Comma,
  # just return the Id.
  # Otherwise, polishize the lexemes.
  def id_expression(lexemes)
    return get_lexeme_value(lexemes.first) if lexemes.length <= 2
    return polishize(lexemes)
  end
  
  # This method will order a statement
  # into Reverse Polish Notation
  def polishize(lexemes)
    operators = []
    operands = []
    
    operators.push('StartSym')
    
    lexemes.reverse!
    
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
    
    while lexemes.length > 1
      lexemes.each_index do |i|
        lexeme = lexemes[i]
        
        if @@operators.member?(lexeme)
          if lexeme == 'AssignOp'
            lexeme = lexemes.delete_at(i)
            operand = lexemes.delete_at(i - 1)
            id = lexemes.delete_at(i - 2)
            atom = [lexeme, get_lexeme_value(id),
                    get_lexeme_value(operand)]
            @atoms.push(atom)
            break
          elsif lexeme == 'NegOp'
            temp = "_temp#{temp_num}"
            temp_num = temp_num.next
            
            @int_literal_table.push('0') if !@int_literal_table.include?('0')
            zero = "IntLiteral_#{@int_literal_table.index('0')}"
            
            lexemes[i] = temp
            operand = lexemes.delete_at(i - 1)
            atom = ['MinusOp', temp, get_lexeme_value(zero),
                    get_lexeme_value(operand)]
            @atoms.push(atom)
            break
          else
            temp = "_temp#{temp_num}"
            temp_num = temp_num.next
            
            lexemes[i] = temp
            operand2 = lexemes.delete_at(i - 1)
            operand1 = lexemes.delete_at(i - 2)
            atom = [lexeme, temp, get_lexeme_value(operand1),
                    get_lexeme_value(operand2)]
            
            @atoms.push(atom)
            break
          end
        end
      end
    end
    
    # return the last Identifier
    return @atoms.last[1]
  end
  
  # If the lexeme is an Id, return the Id stored in the symbol table.
  # If the lexeme is an IntLiteral, return symbol to reference int.
  # Otherwise, just return the lexeme.
  def get_lexeme_value(lexeme)
    token, value = lexeme.split('_')
    if token == 'Id'
      return @symbol_table[value.to_i]
    elsif token == 'IntLiteral'
      return "_int#{value}"
    else
      return lexeme
    end
  end
  
  def write_sem
    File.open(@sem_path, "w") do |sem|
      @atoms.each {|atom| sem.puts(atom.join(','))}
    end
  end
  
  def write_lis(message)
    File.open(@lis_path, "a") do |file|
      file.puts(message)
    end
  end
  
end