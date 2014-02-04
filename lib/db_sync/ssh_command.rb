require 'net/ssh'

module DbSync
  class SshCommand
    attr_reader :server, :command

    def initialize(server, command)
      @server = server
      @command = "ls -al ~"
    end

    def run
      Net::SSH.start('bs-stage01-clone.c45233.blueboxgrid.com', 'deploy') do |ssh|
        channel = ssh.open_channel do |ch|
          ch.exec @command do |ch, success|
            raise "could not execute command" unless success

            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
              $stdout.print data
            end

            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
              $stderr.print data
            end

            # ch.on_close { puts "done!" }
          end
        end

        channel.wait
      end
    end

  end
end