module ClientCli
  class CLI
    DEFAULT_DATA_FILE = 'data/clients.json'

    def initialize(args = ARGV)
      @args = args
      @options = {}
      @data_file = DEFAULT_DATA_FILE
    end

    def run
      if @args.empty?
        show_interactive_menu
      else
        parse_arguments
        case @options[:command]
        when :search
          handle_search
        when :duplicates
          handle_duplicates
        else
          puts "Unknown command: #{@options[:command]}"
          exit 1
        end
      end
    rescue ClientCli::Error => e
      puts "Error: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "Unexpected error: #{e.message}"
      exit 1
    end

    private

    def parse_arguments
      args = @args.dup

      # Parse file option
      file_index = args.find_index { |arg| ['-f', '--file'].include?(arg) }
      if file_index
        if file_index + 1 >= args.length
          puts 'Error: --file option requires a value'
          exit 1
        end
        @data_file = args[file_index + 1]
        args.delete_at(file_index + 1) # Remove the file path
        args.delete_at(file_index)     # Remove the -f/--file flag
      end

      # Parse command
      if args.empty?
        puts 'Error: Command is required'
        exit 1
      end

      command = args.shift
      case command
      when 'search'
        @options[:command] = :search
        @options[:field] = args.shift || 'full_name' # Default to full_name
        @options[:query] = args.shift
      when 'duplicates'
        @options[:command] = :duplicates
        @options[:field] = args.shift || 'email' # Default to email
      else
        @options[:command] = command.to_sym
      end
    end

    def handle_search
      unless @options[:query]
        puts 'Error: Search query is required'
        puts "Usage: #{$0} search [FIELD] QUERY"
        exit 1
      end

      manager = ClientManager.new(@data_file)
      results = manager.search_by_field(@options[:field], @options[:query])

      if results.empty?
        puts "No records found with #{@options[:field]} matching '#{@options[:query]}'"
      else
        puts "Found #{results.size} record(s) with #{@options[:field]} matching '#{@options[:query]}':"
        puts ''
        results.each do |record|
          puts format_record(record)
        end
      end
    end

    def handle_duplicates
      manager = ClientManager.new(@data_file)
      duplicates = manager.find_duplicates_by_field(@options[:field])

      if duplicates.empty?
        puts "No duplicate #{@options[:field]} values found in the dataset"
      else
        duplicates.each do |duplicate|
          duplicate[:clients].each do |record|
            puts "#{format_record(record)}"
          end
          puts ''
        end
        puts "Found #{duplicates.size} #{@options[:field]} value(s) with duplicates:"
      end
    end

    def show_interactive_menu
      puts 'ClientCli - Client Data Management Tool'
      puts '========================================='
      puts ''
      puts 'What would you like to do?'
      puts '1. Search records'
      puts '2. Find duplicates'
      puts '3. Exit'
      puts ''
      print 'Enter your choice (1-3): '

      choice = gets.chomp

      case choice
      when '1'
        interactive_search
      when '2'
        interactive_duplicates
      when '3'
        puts 'Goodbye!'
        exit 0
      else
        puts 'Invalid choice. Please enter 1, 2, or 3.'
        show_interactive_menu
      end
    end

    def interactive_search
      puts ''
      print "Enter field to search (or press Enter for 'full_name'): "
      field = gets.chomp
      field = 'full_name' if field.empty?

      print 'Enter search query: '
      query = gets.chomp

      if query.empty?
        puts 'Search query cannot be empty.'
        return
      end

      @options[:command] = :search
      @options[:field] = field
      @options[:query] = query

      handle_search
    end

    def interactive_duplicates
      puts ''
      print "Enter field to check for duplicates (or press Enter for 'email'): "
      field = gets.chomp
      field = 'email' if field.empty?

      @options[:command] = :duplicates
      @options[:field] = field

      handle_duplicates
    end

    def format_record(record)
      record.map { |key, value| "#{key.capitalize}: #{value}" }.join(', ')
    end
  end
end
