# Chris Durtschi
# CS 4820
# David Hart
# MicroCom - Lexical Phase

class LexicalScanner

  def initialize(mic_path, lex_path, lis_path, lexemes,
      symbol_table, int_literal_table)
    @mic_path = mic_path
    @lex_path = lex_path
    @lis_path = lis_path
    
    # this will store this individual lexeme symbols
    @lexemes = lexemes
    
    # the symbol table stores Ids
    @symbol_table = symbol_table
    @int_literal_table = int_literal_table
    
    @stream = get_stream
    @pointer = 0
    @line_num = 1
    
    # the buffer is used when processing Ids or Int Literals
    @buffer = []
    
    # this will store any errors, and the line number it occured on
    @errors = []
  end
  
  def scan
    # implement scanner psuedo-code from handout
    while char = read
      if char.match(/[A-Z]|[a-z]/)
        buffer_char(char)
        process_id
      elsif char.match(/[0-9]/)
        buffer_char(char)
        process_int_literal
      elsif char == '('
        @lexemes.push('LParen')
      elsif char == ')'
        @lexemes.push('RParen')
      elsif char == ';'
        @lexemes.push('SemiColon')
      elsif char == ','
        @lexemes.push('Comma')
      elsif char == '+'
        @lexemes.push('PlusOp')
      elsif char == '*'
        @lexemes.push('MultiplyOp')
      elsif char == '/'
        @lexemes.push('DivideOp')
      elsif char == '='
        @lexemes.push('EqSym')
      elsif char == '!'
        if inspect == '='
          advance
          @lexemes.push('NotEqSym')
        else
          @errors.push("ERROR on line #{@line_num}: Illegal starting token for symbol: #{char}")
        end
      elsif char == '<'
        if inspect == '='
          advance
          @lexemes.push('LsEqSym')
        else
          @lexemes.push('LsSym')
        end
      elsif char == '>'
        if inspect == '='
          advance
          @lexemes.push('GrEqSym')
        else
          @lexemes.push('GrSym')
        end
      elsif char == ':'
        if inspect == '='
          advance
          @lexemes.push('AssignOp')
        else
          @errors.push("ERROR on line #{@line_num}: Illegal starting token for symbol: #{char}")
        end
      elsif char == '-'
        if inspect == '-'
          nil until read == "\n"
          @lexemes.push('@')
          @line_num = @line_num.next
        else
          @lexemes.push('MinusOp')
        end
      elsif char == "\n"
        @lexemes.push('@')
        @line_num = @line_num.next
      elsif !char.match(/\s/)
        @errors.push("ERROR on line #{@line_num}: Invalid character: #{char}")
      end
      
      clear_buffer
    end
    
    @lexemes.push('EofSym')
    
    # if there are no errors, write the .lex file,
    # otherwise, write errors to .lis file.
    if @errors.empty?
      message = "Lexical Phase Successful - .lex file generated"
      write_lis_message(message)
      write_lex
      puts message
      return true
    else
      message = "Lexical Phase NOT Successful"
      write_lis_message(message)
      write_errors
      puts message
      return false
    end
    
  end
  
  private
  
  def buffer
    @buffer.join
  end
  
  def buffer_char(char)
    @buffer.push(char)
  end
  
  def clear_buffer
    @buffer = []
  end
  
  def eof?
    return @stream[@pointer] == nil
  end
  
  def advance
    @pointer = @pointer.next
  end
  
  def inspect
    char = @stream[@pointer]
    return char ? char.chr : nil
  end
    
  def read
    char = @stream[@pointer]
    @pointer = @pointer.next
    return char ? char.chr : nil
  end
  
  def check_reserved
    if buffer == 'begin'
      @lexemes.push('BeginSym')
    elsif buffer == 'end'
      @lexemes.push('EndSym')
    elsif buffer == 'read'
      @lexemes.push('ReadSym')
    elsif buffer == 'write'
      @lexemes.push('WriteSym')
    elsif buffer == 'if'
      @lexemes.push('IfSym')
    elsif buffer == 'then'
      @lexemes.push('ThenSym')
    elsif buffer == 'else'
      @lexemes.push('ElseSym')
    elsif buffer == 'endif'
      @lexemes.push('EndIfSym')
    elsif buffer == 'while'
      @lexemes.push('WhileSym')
    elsif buffer == 'loop'
      @lexemes.push('LoopSym')
    elsif buffer == 'endloop'
      @lexemes.push('EndLoopSym')
    else
      insert_symbol_table
    end
  end
  
  def insert_symbol_table
    if (buffer.length > 7)
      @errors.push("ERROR on line #{@line_num}: Id too long: #{buffer}")
    else
      @symbol_table.push(buffer) if !@symbol_table.include?(buffer)
      @lexemes.push("Id_#{@symbol_table.index(buffer)}")
    end
  end
  
  def process_id
      while inspect        
        if inspect.match(/[A-Z]|[a-z]|[0-9]|_/)
          buffer_char(inspect)
          advance
        else
          break
        end
      end
      
      check_reserved
  end
  
  def process_int_literal
    while inspect
      if inspect.match(/[0-9]/)
        buffer_char(inspect)
        advance
      else
        break
      end
    end
    
    if buffer.length > 4
      @errors.push("ERROR on line #{@line_num}: Int literal too long: #{buffer}")
    else
      @int_literal_table.push(buffer) if !@int_literal_table.include?(buffer)
      @lexemes.push("IntLiteral_#{@int_literal_table.index(buffer)}")
    end
  end
  
  def get_stream
    # write .lis file with line numbers,
    # read each line to store in @stream
    buffer = []
    
    File.open(@lis_path, "w") do |lis|
      File.open(@mic_path, "r") do |mic|
        while line = mic.gets
          lis << "#{"%03s" % mic.lineno}    #{line}"
          buffer.push(line)
        end
      end
    end
    
    return buffer.join
  end
  
  def write_lex
    File.open(@lex_path, "w") do |lex|
      @lexemes.each {|l| lex.puts(l)}
    end
  end
  
  def write_errors
    File.open(@lis_path, "a") do |lis|
      @errors.each {|e| lis.puts(e)}
    end
  end
  
  def write_lis_message(message)
    File.open(@lis_path, "a") do |lis|
      lis.puts
      lis.puts(message)
    end
  end
  
end