require 'net/ssh'

module DbSync
  class SshCommand
    def initialize(host: host, user: user, password: password, command: command)
      @hostname = host
      @username = user
      @password = password
      @command = command
    end

    def run
      options = {}
      options[:password] = @password if @password

      Net::SSH.start(@hostname, @username, options) do |ssh|
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