require_relative '../lib/client_cli'
require 'json'
require 'tempfile'

RSpec.describe ClientCli do
  let(:sample_data) do
    [
      { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@example.com' },
      { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@example.com' },
      { 'id' => 3, 'full_name' => 'John Johnson', 'email' => 'john.doe@example.com' }
    ]
  end

  let(:temp_file) do
    file = Tempfile.new(['clients', '.json'])
    file.write(JSON.pretty_generate(sample_data))
    file.close
    file.path
  end

  after { File.unlink(temp_file) if File.exist?(temp_file) }

  describe ClientCli::Client do
    let(:client) { described_class.new({ 'id' => 1, 'full_name' => 'John', 'email' => 'john@test.com' }) }

    it 'initializes with correct attributes' do
      expect(client.id).to eq(1)
      expect(client.full_name).to eq('John')
      expect(client.email).to eq('john@test.com')
    end

    it 'formats to_s correctly' do
      expect(client.to_s).to eq('ID: 1, Name: John, Email: john@test.com')
    end
  end

  describe ClientCli::ClientManager do
    let(:manager) { described_class.new(temp_file) }

    it 'searches by name' do
      results = manager.search_by_name('john')
      expect(results.size).to eq(2)
      expect(results.all? { |c| c.full_name.downcase.include?('john') }).to be true
    end

    it 'finds duplicate emails' do
      duplicates = manager.find_duplicate_emails
      expect(duplicates.size).to eq(1)
      expect(duplicates.first[:email]).to eq('john.doe@example.com')
      expect(duplicates.first[:count]).to eq(2)
    end

    it 'returns empty for no matches' do
      expect(manager.search_by_name('nonexistent')).to be_empty
    end
  end
end
