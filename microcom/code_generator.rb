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
  end
  
  def generate
    create_instructions_from_atoms
    
    @instructions.push({:operator => 'STOP'})
    
    add_symbols
    add_int_literals
    add_temps
    
    @instructions.push({:operator => 'END'})

    write_unoptimized_tas

    optimize_instructions
    
    write_optimized_tas
    
    message = 'Code generation successful - .tas file generated'
    write_lis(message)
    puts(message)
  end
  
  private
  
  def create_instructions_from_atoms
    @atoms.each do |atom|
      operator = atom.first
      if @@arithmetic_operators.include?(operator)
        generate_arithmetic(atom)
      elsif @@io_operators.include?(operator)
        generate_io(atom)
      elsif operator == 'AssignOp'
        generate_assignment(atom)
      else
        raise 'First atom is not PlusOp, MinusOp, MultiplyOp, DivideOp, 
            AssignOp, ReadSym, or WriteSym'
      end
    end
  end
  
  def generate_arithmetic(atom)
    second = atom.pop
    first = atom.pop
    result = atom.pop
    operator = atom.pop
    
    @instructions.push({:operator => 'LD', :operand => first})
    @instructions.push({:operator => @@arithmetic_operators[operator], 
        :operand => second})
    @instructions.push({:operator => 'STO', :operand => result})
  end
  
  def generate_io(atom)
    value = atom.pop
    operator = atom.pop
    
    @instructions.push({:operator => @@io_operators[operator], 
        :operand => value})
  end
  
  def generate_assignment(atom)
    value = atom.pop
    result = atom.pop
    
    @instructions.push({:operator => 'LD', :operand => value})
    @instructions.push({:operator => 'STO', :operand => result})
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
  
  def optimize_instructions
    @instructions.reverse!
    optimized = []
    
    while code = @instructions.pop
      if code[:operator] == 'STO'
        # Find of if the next operation is LD
        next_code = @instructions.pop
        if next_code && next_code[:operator] == 'LD' && 
            next_code[:operand] == code[:operand]
          if temp_symbol?(code[:operand])
            # This is a STO/LD combo with a temporary variable,
            # discard both instructions and continue.
            next
          else
            # This is a STO/LD combo with a non-temporary variable,
            # keep the STO, discard the LD.
            optimized.push(code)
          end
        else
          # This is not a STO/LD combo, push both instructions back
          # to the optimized stack.
          optimized.push(code)
          optimized.push(next_code)
        end
      else
        # This is not a STO instruction, no optimization needed,
        # push code onto optimized stack.
        optimized.push(code)
      end
    end
    
    @instructions = optimized
  end
  
  def temp_symbol?(symbol)
    return symbol.match(/^_temp\d+$/)
  end
  
  def write_optimized_tas
    write_tas(@tas_path)
  end
  
  def write_unoptimized_tas
    write_tas('unoptimized_' + @tas_path)
  end
  
  def write_tas(tas_path)
    File.open(tas_path, "w") do |file|
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