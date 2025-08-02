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
        @options[:query] = args.shift
      when 'duplicates'
        @options[:command] = :duplicates
      else
        @options[:command] = command.to_sym
      end
    end

    def handle_search
      unless @options[:query]
        puts 'Error: Search query is required'
        puts "Usage: #{$0} search QUERY"
        exit 1
      end

      manager = ClientManager.new(@data_file)
      results = manager.search_by_name(@options[:query])

      if results.empty?
        puts "No clients found matching '#{@options[:query]}'"
      else
        puts "Found #{results.size} client(s) matching '#{@options[:query]}':"
        puts ''
        results.each do |client|
          puts client
        end
      end
    end

    def handle_duplicates
      manager = ClientManager.new(@data_file)
      duplicates = manager.find_duplicate_emails

      if duplicates.empty?
        puts 'No duplicate emails found in the dataset'
      else
        puts "Found #{duplicates.size} email(s) with duplicates:"
        puts ''
        duplicates.each do |duplicate|
          puts "Email: #{duplicate[:email]} (#{duplicate[:count]} clients)"
          duplicate[:clients].each do |client|
            puts "  - #{client}"
          end
          puts ''
        end
      end
    end
  end
end
