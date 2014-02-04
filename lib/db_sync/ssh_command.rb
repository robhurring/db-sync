require 'net/ssh'

module DbSync
  class SshCommand
    attr_reader :server, :command

    def initialize(server, command)
      @server = server
      @command = command
    end

    def run
      Net::SSH.start('bs-stage01-clone.c45233.blueboxgrid.com', 'deploy') do |ssh|

        ssh.exec!("ls -al ~") do |channel, stream, data|
          STDOUT << data if stream == :stdout
        end

      end
    end
  end
end