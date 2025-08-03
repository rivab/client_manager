require_relative '../lib/client_cli'
require 'json'
require 'tempfile'

RSpec.describe ClientCli do
  describe ClientCli::ClientManager do
    let(:manager) { described_class.new('data/test_clients.json') }

    it 'searches by name' do
      results = manager.search_by_name('Bob')
      expect(results.size).to eq(3)
      puts results
      expect(results.all? { |r| r['full_name'].downcase.include?('bob') }).to be true
    end

    it 'searches for the name not in the file' do
      results = manager.search_by_name('abc')
      expect(results.size).to eq(0)
    end

    it 'finds duplicate emails' do
      duplicates = manager.find_duplicate_emails
      expect(duplicates.size).to eq(1)
      expect(duplicates.first[:email]).to eq('bob@music.com')
      expect(duplicates.first[:count]).to eq(2)
    end

    it 'returns empty for no matches' do
      expect(manager.search_by_name('nonexistent')).to be_empty
    end
  end
end
