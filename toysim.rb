# Chris Durtschi
# CS 4820
# David Hart
# Toy Sim


class ToySim

  MEM_SIZE = 100
  INT_RANGE = -9999..9999
  INT_REGEX = /^-?\d{1,4}$/
  
  def initialize(program_path)
    load_program(program_path)
    @accumulator = 0
    @instruction_register = 0
    @program_counter = 0
    @cycle = true
  end

  def run
    begin
      while @cycle
        fetch
        execute
      end
    rescue
      puts "Error: #{$!}"
      @cycle = false
    end
  end
  
  private
  
  def load_program(program_path)
    program_path += '.obj' if !program_path.match(/^\w+\.obj$/)
    @memory = []
    MEM_SIZE.times { @memory.push(0) }
    
    begin
      File.open(program_path, "r") do |file|
        index = 0
        while instr = file.gets
          instr.chomp!
          raise "Program overflow" if index == MEM_SIZE
          raise "Invalid instruction: #{instr}" if !instr.match(INT_REGEX)
          @memory[index] = instr.to_i
          index = index.next
        end
      end      
    rescue
      puts "Error: #{$!}"
      exit
    end
  end
  
  def fetch
    @instruction_register = @memory[@program_counter]
    @program_counter = @program_counter.next
  end
  
  def execute
    instruction = @instruction_register / 100
    address = @instruction_register % 100
    
    raise "Address is out of bounds: #{address}" if address >= MEM_SIZE

    case instruction
      when 0
        stop
      when 1
        load(address)
      when 2
        store(address)
      when 3
        add(address)
      when 4
        subtract(address)
      when 5
        multiply(address)
      when 6
        divide(address)
      when 7
        input(address)
      when 8
        output(address)
      when 9
        unconditional_branch(address)
      when 10
        branch_greater_than_zero(address)
      when 11
        branch_equals_zero(address)
      else
        raise "#{instruction} is not a valid instruction"
      end      
    end
    
  def stop
    @cycle = false
  end
  
  def load(address)
    @accumulator = @memory[address]
  end
  
  def store(address)
    @memory[address] = @accumulator
  end
  
  def add(address)
    sum = @accumulator + @memory[address]
    check_overflow(sum)
    @accumulator = sum
  end
  
  def subtract(address)
    difference = @accumulator - @memory[address]
    check_overflow(difference)
    @accumulator = difference
  end
  
  def multiply(address)
    product = @accumulator * @memory[address]
    check_overflow(product)
    @accumulator = product
  end
  
  def divide(address)
    divisor = @memory[address]
    raise 'Division by zero' if divisor == 0
    quotient = @accumulator / divisor
    check_overflow(quotient)
    @accumulator = quotient
  end
  
  def input(address)
    print '? '
    input = gets.chomp
    if input.match(INT_REGEX)
      @memory[address] = input.to_i
    else
      puts "Input must be in the range #{INT_RANGE.min} to #{INT_RANGE.max}"
      input(address)
    end
  end
  
  def output(address)
    puts "output=#{@memory[address]}"
  end
  
  def unconditional_branch(address)
    @program_counter = address
  end
  
  def branch_greater_than_zero(address)
    unconditional_branch(address) if @accumulator > 0
  end
  
  def branch_equals_zero(address)
    unconditional_branch(address) if @accumulator == 0
  end
  
  def check_overflow(value)
    raise "Integer overflow: #{value}" if !INT_RANGE.member?(value)
  end
  
end

while true
	puts "\nEnter name of .obj program, with or without extension, or 'quit' to exit:"
	path = gets.chomp
	exit if path == 'quit'
	toysim = ToySim.new(path)
	toysim.run
end