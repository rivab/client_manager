require 'json'

module ClientCli
  class ClientManager
    def initialize(data_file_path)
      @data_file_path = data_file_path
      @data = load_data
    end

    def search_by_name(query)
      search_by_field('full_name', query)
    end

    def search_by_field(field, query)
      return [] if query.nil? || query.strip.empty?

      validate_field_exists(field)

      normalized_query = query.strip.downcase
      @data.select do |record|
        field_value = record[field]
        field_value&.to_s&.downcase&.include?(normalized_query)
      end
    end

    def find_duplicate_emails
      find_duplicates_by_field('email')
    end

    def find_duplicates_by_field(field)
      validate_field_exists(field)

      field_groups = @data.group_by { |record| record[field] }
      duplicates = field_groups.select { |_value, records| records.size > 1 }

      duplicates.map do |value, records|
        {
          value:,
          clients: records,
          count: records.size,
          email: value # Keep for backward compatibility
        }
      end
    end

    def total_clients
      @data.size
    end

    private

    def load_data
      raise ClientCli::Error, "Data file not found: #{@data_file_path}" unless File.exist?(@data_file_path)

      begin
        data = JSON.parse(File.read(@data_file_path))
        validate_data_structure(data)
        data
      rescue JSON::ParserError => e
        raise ClientCli::Error, "Invalid JSON format: #{e.message}"
      rescue StandardError => e
        raise ClientCli::Error, "Error loading data: #{e.message}"
      end
    end

    def validate_data_structure(data)
      raise ClientCli::Error, "Expected JSON array, got #{data.class}" unless data.is_a?(Array)

      data.each_with_index do |item, index|
        raise ClientCli::Error, "Expected object at index #{index}, got #{item.class}" unless item.is_a?(Hash)
      end
    end

    def validate_field_exists(field)
      return if @data.empty?

      # Check if any record has this field
      has_field = @data.any? { |record| record.key?(field) }

      return if has_field

      available_fields = @data.first.keys.join(', ')
      raise ClientCli::Error, "Field '#{field}' not found. Available fields: #{available_fields}"
    end
  end
end
