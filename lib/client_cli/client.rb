module ClientCli
  class Client
    attr_reader :id, :full_name, :email

    def initialize(data)
      @id = data['id']
      @full_name = data['full_name']
      @email = data['email']
    end

    def to_s
      "ID: #{id}, Name: #{full_name}, Email: #{email}"
    end

    def ==(other)
      other.is_a?(Client) && id == other.id
    end

    def hash
      id.hash
    end
  end
end
