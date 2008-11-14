# Chris Durtschi
# CS 4820
# David Hart
# MicroCom - Syntactical Phase

class SyntacticalScanner

  def initialize(lex_path, lis_path)
    @lex_path = lex_path
    @lis_path = lis_path
    
    @lexemes = []
    
    File.open(lex_path, "r") do |file|
      while line = file.gets
        @lexemes.push(line.chomp)
      end
    end
    
    @pointer = 0
    @line_num = 1
    
    @errors = []    
  end

  def scan
    system_goal
    
    message = "Syntactical Phase Successful" if @errors.empty?
    message = "Syntactical Phase NOT Successful" if !@errors.empty?
    write_lis(message)
    write_lex if @errors.empty?
    puts message
  end
  
  def write_lis(message)
    File.open(@lis_path, "a") do |file|
      file.puts "#{message}\n\n"
      @errors.each {|e| file.puts e}
    end
  end
  
  def write_lex
    File.open(@lex_path, "w") do |file|
      @lexemes.each {|l| file.puts l}
    end
  end
      
  def next_token
    while true
      lexeme = @lexemes[@pointer]
      if (lexeme == '@')
        @line_num = @line_num.next
        @pointer = @pointer.next
      else
        break
      end
    end
    
    lexeme = lexeme.split('_').first if lexeme
    
    return lexeme
  end
  
  # If a syntax error is encountered,
  # we want to stop processing the current line,
  # and return back to statement_list to process the next statement.
  def syntax_error(expected, found)
    expected = expected.join(', ') if expected.class == Array
    @errors.push("SYNTAX ERROR on line #{@line_num}: Expected #{expected}, found #{found}")
    next_line
  end
  
  # Next line will move the pointer to the beginning of the next line.
  # This will be called by syntax_error, in order to begin processing
  # again on the line following the line with the sytax error.
  def next_line
    while true
      if (@lexemes[@pointer] != nil && @lexemes[@pointer] != '@')
        @pointer = @pointer.next
      else
        break
      end
    end
  end
    
  # If symbol is successfully matched, advance @pointer to next token and return true,
  # otherwise call syntax_error and return false.
  def match(symbol)
    if (next_token != symbol)
      syntax_error(symbol, next_token)
      return false
    else
      @pointer = @pointer.next
      return true
    end
  end
  
  # system_goal is starting non-terminal of our CFG
  def system_goal
    program
    match('EofSym')
  end
  
  def program
    match('BeginSym')
    statement_list
    match('EndSym')
  end
  
  # All methods called by statement_list will have a boolean return value,
  # indicating if there were any syntax errors encountered.
  # If a syntax error is encountered, we want to stop processing the current statement,
  # and return to statement_list to process the next statement.
  def statement_list
    statement
    while true
      if (next_token == 'Id' || next_token == 'ReadSym' || next_token == 'WriteSym')
        statement
      else
        break
      end
    end
  end
  
  def statement
    case next_token
      when 'Id'
        return false if !match('Id')
        return false if !match('AssignOp')
        return false if !expression
        return false if !match('SemiColon')
      when 'ReadSym'
        return false if !match('ReadSym')
        return false if !match('LParen')
        return false if !id_list
        return false if !match('RParen')
        return false if !match('SemiColon')
      when 'WriteSym'
        return false if !match('WriteSym')
        return false if !match('LParen')
        return false if !expression_list
        return false if !match('RParen')
        return false if !match('SemiColon')
      else
        syntax_error(['Id', 'ReadSym', 'WriteSym'], next_token)
        return false
    end
      
    return true
  end
  
  def id_list
    return false if !match('Id')
    while true
      if (next_token == 'Comma')
        return false if !match('Comma')
        return false if !match('Id')
      else
        return true
      end
    end
  end
  
  def expression_list
    return false if !expression
    while true
      if (next_token == 'Comma')
        return false if !match('Comma')
        return false if !expression
      else
        return true
      end
    end
  end
  
  def expression
    return false if !factor
    while true
      if (next_token == 'PlusOp' || next_token == 'MinusOp')
        return false if !add_op
        return false if !factor
      else
        return true
      end
    end
  end
  
  def factor
    return false if !primary
    while true
      if (next_token == 'MultiplyOp' || next_token == 'DivideOp')
        return false if !mult_op
        return false if !primary
      else
        return true
      end
    end
  end
  
  def primary
    case next_token
      when 'MinusOp'
        replace_neg_op
        return false if !match('NegOp')
        return false if !primary
      when 'LParen'
        return false if !match('LParen')
        return false if !expression
        return false if !match('RParen')
      when 'Id'
        return false if !match('Id')
      when 'IntLiteral'
        return false if !match('IntLiteral')
      else
        syntax_error(['MinusOp', 'LParen', 'Id', 'IntLiteral'], next_token)
        return false
    end
      
    return true
  end
  
  def mult_op
    case next_token
      when 'MultiplyOp'
        return false if !match('MultiplyOp')
      when 'DivideOp'
        return false if !match('DivideOp')
      else
        syntax_error(['MultiplyOp', 'DivideOp'], next_token)
        return false
    end
    
    return true
  end
  
  def add_op
    case next_token
      when 'PlusOp'
        return false if !match('PlusOp')
      when 'MinusOp'
        return false if !match('MinusOp')
      else
        syntax_error(['PlusOp', 'MinusOp'], next_token)
        return false
    end
    
    return true
  end
  
  def replace_neg_op
    @lexemes[@pointer] = 'NegOp'
  end
  
end
