module ClientCli
  class CLI
    DEFAULT_DATA_FILE = 'data/clients.json'

    def initialize(args = ARGV)
      @args = args
      @options = {}
      @data_file = DEFAULT_DATA_FILE
    end

    def run
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
        puts "Found #{duplicates.size} #{@options[:field]} value(s) with duplicates:"
        puts ''
        duplicates.each do |duplicate|
          puts "#{@options[:field].capitalize}: #{duplicate[:value]} (#{duplicate[:count]} records)"
          duplicate[:clients].each do |record|
            puts "  - #{format_record(record)}"
          end
          puts ''
        end
      end
    end

    def format_record(record)
      record.map { |key, value| "#{key.capitalize}: #{value}" }.join(', ')
    end
  end
end
