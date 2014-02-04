require 'optparse'
require_relative './config'
require_relative './ssh_command'
require_relative './local_command'

module DbSync
  class Cli
    attr_reader :argv

    def initialize(argv)
      @argv = argv
    end

    def run
      method = (argv.shift || 'help').to_sym
      if [:init, :pull, :sync, :version].include? method
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

    def init
      filename = argv.shift
      DbSync::Config.init!(filename)
    end

    # db-sync pull beautysage:qa > ~/Desktop/somefile.dump
    def pull
      opts = parse_opts(:pull)
      config = get_config(opts)
      app = get_app(config, opts[:from])

      command = SshCommand.new(
        host: app['server']['host'],
        user: app['server']['user'],
        password: app['server']['password'],
        command: 'ls -al ~'
      )

      command.run
    end

    # db-sync sync beautysage:qa beautysage:local
    def sync
      opts = parse_opts(:sync)
      config = get_config(opts)

      puts opts.inspect
    end

    def get_config(opts = {})
      if opts[:config]
        DbSync::Config.load!(opts[:config])
      else
        DbSync::Config.load_default!
      end
    end

    def get_app(config, opts = {})
      data = config.app(opts[:server])

      unless data.has_key?(opts[:environment])
        puts "Could not find environment '#{opts[:environment]}' for app '#{opts[:server]}'!"
        exit 1
      end

      data[opts[:environment]]
    end

    def help
      puts %{
        Options
        =======
        pull      Pull a database from a remote server to a file
        sync      Pull a database from a remote server to your localhost
        init      Create a db-sync config file (default: ~/.db-sync.yml)
        version   db-sync version

        Add '-h' to any command to see their usage
      }.split($/).map(&:lstrip).join($/)
    end

    def parse_opts(cmd)
      opts = {
        from: {
          server: nil,
          environment: nil
        },
        to: {
          server: nil,
          environment: nil
        }
      }

      OptionParser.new do |o|
        case cmd
        when :pull
          o.banner = "Usage: #{File.basename($0)} #{cmd} [OPTIONS] FROM:ENVIRONMENT > outfile.dump"
          o.define_head "Pull a database from a remote server"
        when :sync
          o.banner = "Usage: #{File.basename($0)} #{cmd} [OPTIONS] FROM:ENVIRONMENT TO:ENVIRONMENT"
          o.define_head "Sync a database from a remote server to a local database"
        end

        o.on("-c", "--config FILENAME", "Path to db-sync config (default: ~/.db-sync.yml)") { |v| opts[:config] = v }
        o.parse!(argv)

        opts[:from][:server] = from = argv.shift
        opts[:to][:server] = to = argv.shift

        if from.to_s.include?(':')
          opts[:from][:server], opts[:from][:environment] = from.split(':')
        end

        if to.to_s.include?(':')
          opts[:to][:server], opts[:to][:environment] = to.split(':')
        end

        if opts[:from][:server].nil?
          $stderr.puts "Missing FROM server name!"
          puts o
          exit 1
        end

        if opts[:from][:environment].nil?
          $stderr.puts "Missing FROM environment!"
          puts o
          exit 1
        end

        if cmd == :sync
          if opts[:to][:server].nil?
            $stderr.puts "Missing TO server name!"
            puts o
            exit 1
          end

          if opts[:to][:environment].nil?
            $stderr.puts "Missing TO environment!"
            puts o
            exit 1
          end
        end
      end

      opts
    end

  end
end
