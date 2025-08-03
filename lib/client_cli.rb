#!/usr/bin/env ruby

require_relative 'client_cli/cli'
require_relative 'client_cli/client_manager'

module ClientCli
  class Error < StandardError; end
end
