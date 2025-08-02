require 'json'

module ClientCli
  class ClientManager
    def initialize(data_file_path)
      @data_file_path = data_file_path
      @clients = load_clients
    end

    def search_by_name(query)
      return [] if query.nil? || query.strip.empty?

      normalized_query = query.strip.downcase
      @clients.select do |client|
        client.full_name.downcase.include?(normalized_query)
      end
    end

    def find_duplicate_emails
      email_groups = @clients.group_by(&:email)
      duplicates = email_groups.select { |_email, clients| clients.size > 1 }

      duplicates.map do |email, clients|
        {
          email:,
          clients:,
          count: clients.size
        }
      end
    end

    def total_clients
      @clients.size
    end

    private

    def load_clients
      raise ClientCli::Error, "Data file not found: #{@data_file_path}" unless File.exist?(@data_file_path)

      begin
        data = JSON.parse(File.read(@data_file_path))
        validate_data_structure(data)

        data.map { |client_data| Client.new(client_data) }
      rescue JSON::ParserError => e
        raise ClientCli::Error, "Invalid JSON format: #{e.message}"
      rescue StandardError => e
        raise ClientCli::Error, "Error loading client data: #{e.message}"
      end
    end

    def validate_data_structure(data)
      raise ClientCli::Error, "Expected JSON array, got #{data.class}" unless data.is_a?(Array)

      data.each_with_index do |item, index|
        raise ClientCli::Error, "Expected object at index #{index}, got #{item.class}" unless item.is_a?(Hash)

        required_fields = %w[id full_name email]
        missing_fields = required_fields - item.keys
        unless missing_fields.empty?
          raise ClientCli::Error, "Missing required fields at index #{index}: #{missing_fields.join(', ')}"
        end
      end
    end
  end
end
