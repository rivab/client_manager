#!/usr/bin/env ruby

require_relative 'client_cli/cli'
require_relative 'client_cli/client_manager'
require_relative 'client_cli/client'

module ClientCli
  class Error < StandardError; end
end
