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
    
    @instructions.push({:operator => 'STOP'})
    
    @symbol_table.each do |symbol|
      @instructions.push({:label => "#{symbol}:", :operator => 'DC', 
          :operand => 0})
    end
    
    @int_literal_table.each do |int|
      id = "_int#{@int_literal_table.index(int)}:"
      @instructions.push({:label => id, :operator => 'DC', :operand => int})
    end
    
    write_tas
    message = 'Code generation successful - .tas file generated'
    write_lis(message)
    puts(message)
  end
  
  private
  
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