# Chris Durtschi
# CS 4820
# David Hart
# Toy Assembler

class ToyAsm

    LABEL_SIZE = 7
    OPCODES = ['STOP', 'LD', 'STO', 'ADD', 'SUB', 'MPY', 'DIV', 'IN', 'OUT', 'B', 'BGTR', 'BZ']


    # Initialize instance variables.
    # @instructions will contain a collection of hash objects,
    # that represent the contents of each line of the .tas file.
    # The following symbols are used in the hash:
    #   :line => the entire contents of the line
    #   :line_counter => the line number of the line
    #   :location_counter => the TOYCOM memory location of the line
    #   :opcode => the integer opcode value of of the line
    #   :operand => the integer operand value of the line
    #   :label => the label at the beginning of the line
    # @symbol_table is a hash of labels and their memory locations
    def initialize(path)
        @tas_path = path
        @tas_path += '.tas' if !@tas_path.match(/^\w+\.tas$/)
        @lis_path = @tas_path.gsub('.tas', '.lis')
        @obj_path = @tas_path.gsub('.tas', '.obj')
        
        @line_counter = 1
        @location_counter = 0
        
        @symbol_table = {}
        @instructions = []
        
        @errors = []
        @warnings = []
        
        first_pass
    end
    
    private
    
    # Performs the first pass on the .tas file.
    # Creates @symbol_table which we'll use later 
    # to turn labels into memory addresses.    
    def first_pass
        found_end = false
        
        File.open(@tas_path, "r") do |file|        
            while (line = file.gets)
                line.chomp!
                
                code = {}
                code[:line] = line
                code[:line_counter] = @line_counter
                
                tokens = line.strip.split(/\s+/)
                first = tokens.first                
                    
                if (first.match(/^\w+:$/))
                    handle_label(tokens, code)
                elsif (first == 'END')
                    found_end = true
                    break
                elsif (first != 'REM')
                    handle_opcode(tokens, code)
                end
                
                @instructions.push(code)              
                @line_counter = @line_counter.next                              
            end
        end
        
        @warnings.push("END directive not found") if (!found_end)
        
        if (@errors.empty?)
            second_pass
        else
            write_lis
            puts "Errors encountered on first pass, .obj file not created.  See .lis file for details"
        end
    end
    
    
    # Goes through @instructions, and matches labels up with their 
    # memory addresses using @symbol_table.
    # Creates .lis file, and if no @errors were encountered, the .obj file.
    def second_pass
        @instructions.each do |code|
            operand = code[:label]
            if (operand)
                if (@symbol_table.key?(operand))
                    code[:operand] = @symbol_table[operand]
                else
                    @errors.push("Undefined symbol on line #{code[:line_counter]}: #{operand}")
                end
            end
        end
        
        write_obj if (@errors.empty?)
        write_lis
        
        if (!@errors.empty?)
            puts "Errors encountered on second pass, .obj file not created.  See .lis file for details"
        elsif (!@warnings.empty?)
            puts "Warnings encountered on second pass.  See .lis file for details"
        end

        puts ".tas file successfully assembled" if @errors.empty?
    end
    
    
    # Checks the validity of a label, adds label to @symbol_table, then passes
    # on the remaining symbols on the line to handle_opcode.
    def handle_label(tokens, code)
        # There shouldn't be more than 3 symbols on a label line
        if (tokens.length > 3)
            @errors.push("Too many symbols on line #{@line_counter}}")
        else    
            # Strip the : and check if label exceeds size limit
            label = tokens[0].gsub(':', '')
            if (label.length > LABEL_SIZE)
                @errors.push("Label has too many characters on line #{@line_counter}: #{label}")
            else
                # Make sure label hasn't already been defined
                if (@symbol_table.has_key?(label))
                    @errors.push("Duplicate label on line #{@line_counter}: #{label}")
                else
                    @symbol_table[label] = @location_counter
                    handle_opcode(tokens[1..2], code)
                end    
            end        
        end
    end
    
    
    # Checks if the two sybols after a label are valid opcode/label pair,
    # or a valid DC/value pair.
    def handle_opcode(tokens, code)
        # There shouldn't be more than 2 symbols on a label line
        if (tokens.length > 2)
            @errors.push("Too many symbols on line #{@line_counter}")
        else
            opcode = tokens[0]
            operand = tokens[1]
            
            if (OPCODES.include?(opcode))
                code[:opcode] = OPCODES.index(opcode)
                code[:operand] = 0
                code[:label] = operand
                record_location(code)                
            elsif (opcode == 'DC')
                @warnings.push("Missing DC value on line #{@line_counter}") if (!operand)
                
                # If the value is not defined, default to 0
                operand = operand ? operand.to_i : 0
                sign = (operand < 0) ? -1 : 1
                code[:opcode] = (operand.abs / 100).to_i
                code[:operand] = (operand.abs % 100).to_i * sign                
                record_location(code)
            else
                @errors.push("Invalid opcode at line #{@line_counter}: #{opcode}")
            end
        end
    end
    
    
    # Records the current location of the @location_counter,
    # then increments the @location_counter.
    def record_location(code)
        code[:location_counter] = @location_counter
        @location_counter = @location_counter.next
    end
    
    
    # Writes the .lis file using the information stored in @instructions.
    # If their are any @errors or @warnings, print them out at the end of the file.
    def write_lis
        File.open(@lis_path, "w") do |file|
            file << " Line    Relative   Object    Assembly\n"
            file << "Number   Address     Code    Instruction\n\n"
            
            @instructions.each do |code|
              line = code[:line]
              line_counter = code[:line_counter]
              location_counter = code[:location_counter]
              opcode = code[:opcode]
              operand = code[:operand]
              
              file << "#{"%05s" % line_counter}       "
              file << "#{"%02d" % location_counter}      " if location_counter
              file << "        " if !location_counter
              if (opcode && operand)
                sign = (operand < 0) ? '-' : ' '
                file << "#{sign}#{"%02d" % opcode.abs}#{"%02d" % operand.abs}    "
              else
                file << "         "
              end
              file << "#{line}\n"
            end
            
            if @errors.empty?
              file << "\nAssembly was Successful - Object file Created\n\n"
            else
              file << "\nErrors Encountered\n\n"
            end  
            
            @errors.each { |error| file << "ERROR: #{error}\n" }
            @warnings.each { |warning| file << "WARNING: #{warning}\n" }
        end
    end
    
    
    # Writes the .obj file using the information stored in @instructions.
    # Only called if second_pass is successful.    
    def write_obj
        File.open(@obj_path, "w") do |file|
            @instructions.each do |code|
                opcode = code[:opcode]
                operand = code[:operand]
                
                if opcode && operand
                  sign = (operand < 0) ? '-' : ''
                  file << "#{sign}#{"%02d" % opcode.abs}#{"%02d" % operand.abs}\n"
                end
            end
        end    
    end

end

while true
    puts "\nEnter assembler filename, with or without .tas extension, or 'quit' to exit:"
    path = gets.chomp
	exit if path == 'quit'
	
	begin
        ToyAsm.new(path)
    rescue
        puts "Error: #{$!}"
    end
end
