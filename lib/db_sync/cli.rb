require 'optparse'

module DbSync
  class Cli
    attr_reader :argv

    def initialize(argv)
      @argv = argv
    end

    def run
      method = (argv.shift || 'help').to_sym
      if [:pull, :version].include? method
        send(method)
      else
        help
      end
    end

    def version
      require_relative './version'
      puts DbSync::VERSION
      exit 0
    end

    def pull
      opts = parse_opts(:pull)
      puts opts.inspect
    end

    def help
      puts %{
        Options
        =======
        pull      Pull a database from a taps server
        version   Taps version

        Add '-h' to any command to see their usage
      }.split($/).map(&:lstrip).join($/)
    end

    def parse_opts(cmd)
      opts = {
        server: nil,
        environment: 'production'
      }

      OptionParser.new do |o|
        o.banner = "Usage: #{File.basename($0)} #{cmd} [OPTIONS] SERVER[:ENVIRONMENT]"

        case cmd
        when :pull
          o.define_head "Pull a database from a remote server"
        end

        o.on("-e", "--environment", "Pull from this database") { |v| opts[:environment] = v }
        o.parse!(argv)

        opts[:server] = argv.shift

        if opts[:server].include?(':')
          opts[:server], opts[:environment] = opts[:server].split(':')
        end

        if opts[:server].nil?
          $stderr.puts "Missing server name!"
          puts o
          exit 1
        end
      end

      opts
    end

  end
end
