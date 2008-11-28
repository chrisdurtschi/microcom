# Chris Durtschi
# CS 4820
# David Hart
# MicroCom - Code Generation Phase

class CodeGenerator
  
  @@arithmetic_operators = {'PlusOp' => 'ADD', 'MinusOp' => 'SUB', 
      'MultiplyOp' => 'MPY', 'DivideOp' => 'DIV'}
      
  @@io_operators = {'ReadSym' => 'IN', 'WriteSym' => 'OUT'}
  
  def initialize(lis_path, tas_path, atoms, symbol_table, int_literal_table)
    @lis_path = lis_path
    @tas_path = tas_path
    @atoms = atoms
    @symbol_table = symbol_table
    @int_literal_table = int_literal_table
    @instructions = []
    @labels = []
  end
  
  def generate
    create_instructions_from_atoms
    
    @instructions.push({:label => pop_next_label, :operator => 'STOP'})
    
    add_symbols
    add_int_literals
    add_temps
    
    @instructions.push({:operator => 'END'})
    
    optimize_instructions
    
    write_tas
    
    message = 'Code generation successful - .tas file generated'
    write_lis(message)
    puts(message)
  end
  
  private
  
  def create_instructions_from_atoms
    @atoms.reverse!
    while atom = @atoms.pop
      operator = atom.first
      if @@arithmetic_operators.include?(operator)
        generate_arithmetic(atom)
      elsif @@io_operators.include?(operator)
        generate_io(atom)
      elsif operator == 'AssignOp'
        generate_assignment(atom)
      elsif operator == 'Tst'
        generate_test(atom)
      elsif operator == 'Br'
        generate_branch(atom)
      elsif operator == 'Lbl'
        @labels.push(atom.last)
      else
        raise 'First atom is not PlusOp, MinusOp, MultiplyOp, DivideOp, 
            AssignOp, Tst, Lbl, Br, ReadSym, or WriteSym'
      end
    end
  end
  
  def generate_arithmetic(atom)
    second = atom.pop
    first = atom.pop
    result = atom.pop
    operator = atom.pop
    
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => first})
    @instructions.push({:operator => @@arithmetic_operators[operator], 
        :operand => second})
    @instructions.push({:operator => 'STO', :operand => result})
  end
  
  def generate_io(atom)
    value = atom.pop
    operator = atom.pop
    
    @instructions.push({:label => pop_next_label, 
        :operator => @@io_operators[operator], :operand => value})
  end
  
  def generate_assignment(atom)
    value = atom.pop
    result = atom.pop
    
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => value})
    @instructions.push({:operator => 'STO', :operand => result})
  end
  
  def generate_test(atom)
    false_label = atom.pop
    operator = atom.pop
    operand2 = atom.pop
    operand1 = atom.pop
    
    case operator
    when 'EqSym'
      generate_equal_test(operand1, operand2, false_label)
    when 'NotEqSym'
      generate_not_equal_test(operand1, operand2, false_label)
    when 'GrSym'
      generate_gr_ls_test(operand1, operand2, false_label)
    when 'LsSym'
      generate_gr_ls_test(operand2, operand1, false_label)
    when 'GrEqSym'
      generate_gr_ls_eq_test(operand1, operand2, false_label)
    when 'LsEqSym'
      generate_gr_ls_eq_test(operand2, operand1, false_label)
    else
      raise 'Test is not EqSym, NotEqSym, GrSym, LsSym, GrEqSym, or LsEqSym'
    end
  end
  
  def generate_equal_test(operand1, operand2, false_label)
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => operand1})
    @instructions.push({:operator => 'SUB', :operand => operand2})
    @instructions.push({:operator => 'BGTR', :operand => false_label})
    @instructions.push({:operator => 'LD', :operand => operand2})
    @instructions.push({:operator => 'SUB', :operand => operand1})
    @instructions.push({:operator => 'BGTR', :operand => false_label})
  end
  
  def generate_not_equal_test(operand1, operand2, false_label)
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => operand1})
    @instructions.push({:operator => 'SUB', :operand => operand2})
    @instructions.push({:operator => 'BZ', :operand => false_label})
  end
  
  def generate_gr_ls_test(operand1, operand2, false_label)
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => operand2})
    @instructions.push({:operator => 'SUB', :operand => operand1})
    @instructions.push({:operator => 'BGTR', :operand => false_label})
    @instructions.push({:operator => 'BZ', :operand => false_label})
  end
  
  def generate_gr_ls_eq_test(operand1, operand2, false_label)
    @instructions.push({:label => pop_next_label, :operator => 'LD',
        :operand => operand2})
    @instructions.push({:operator => 'SUB', :operand => operand1})
    @instructions.push({:operator => 'BGTR', :operand => false_label})
  end

  def generate_branch(atom)
    @instructions.push({:label => pop_next_label, :operator => 'B',
        :operand => atom.last })
  end
  
  def add_symbols
    @symbol_table.each do |symbol|
      @instructions.push({:label => "#{symbol}:", :operator => 'DC', 
          :operand => '0'})
    end
  end
  
  def add_int_literals
    @int_literal_table.each do |int|
      id = "_int#{@int_literal_table.index(int)}:"
      @instructions.push({:label => id, :operator => 'DC', :operand => int})
    end
  end
  
  def add_temps
    temps = []
    @instructions.each do |code|
      operand = code[:operand]
      if operand && temp_symbol?(operand)
        temps.push(operand) if !temps.include?(operand)
      end
    end
    
    temps.each do |temp|
      @instructions.push({:label => "#{temp}:", :operator => 'DC',
          :operand => '0'})
    end
  end
  
  def pop_next_label
    label = @labels.pop
    return "#{label}:" if label
  end
  
  def optimize_instructions
    @instructions.reverse!
    @labels = []
    optimized = []
    
    while code = @instructions.pop
      if code[:operator] == 'STO'
        # Find out if the next operation is LD
        next_code = @instructions.pop
        if next_code && next_code[:operator] == 'LD' && 
            next_code[:operand] == code[:operand]
          if temp_symbol?(code[:operand])
            # This is a STO/LD combo with a temporary variable,
            # discard both instructions and continue.
            @labels.push(next_code[:label]) if next_code[:label]
            @labels.push(code[:label]) if code[:label]
            next
          else
            # This is a STO/LD combo with a non-temporary variable,
            # keep the STO, discard the LD.
            @labels.push(next_code[:label]) if next_code[:label]
            optimized.push(code)
          end
        else
          # This is not a STO/LD combo, push both instructions back
          # to the optimized stack.
          code[:label] = @labels.pop if !code[:label]
          next_code[:label] = @labels.pop if !next_code[:label]
          optimized.push(code)
          optimized.push(next_code)
        end
      else
        # This is not a STO instruction, no optimization needed,
        # push code onto optimized stack.
        code[:label] = @labels.pop if !code[:label]
        optimized.push(code)
      end
    end
    
    @instructions = optimized
  end
  
  def temp_symbol?(symbol)
    return symbol.match(/^_temp\d+$/)
  end
  
  def write_tas
    File.open(@tas_path, "w") do |file|
      @instructions.each do |code|
        file.printf("%-9s %-5s %s\n", code[:label], code[:operator], 
            code[:operand])
      end
    end
  end
  
  def write_lis(message)
    File.open(@lis_path, "a") do |file|
      file.puts(message)
    end
  end
  
end