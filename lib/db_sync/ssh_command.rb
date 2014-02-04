require 'net/ssh'

module DbSync
  class SshCommand
    attr_reader :server, :command

    def initialize(server, command)
      @server = server
      @command = command
    end

    def run
    end
  end
end