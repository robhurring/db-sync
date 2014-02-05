require 'optparse'

require_relative './config'
require_relative './command'
require_relative './stream'

module DbSync
  class Cli
    attr_reader :argv

    def initialize(argv)
      @argv = argv
    end

    def run
      method = (argv.shift || 'help').to_sym
      if [:init, :list, :dump, :restore, :version].include? method
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

    def list
      opts = {}
      OptionParser.new do |o|
        o.banner = "Usage: #{File.basename($0)} list [OPTIONS]"
        o.define_head "List the current apps and environments in your config"
        o.on("-c", "--config FILENAME", "Path to db-sync config (default: ~/.db-sync.yml)") { |v| opts[:config] = v }
        o.parse!(argv)
      end

      config = get_config(opts)
      delim = '-'

      puts "%-30s | %-50s\n%-30s|%-50s" % ['Application', 'Host', delim*31, delim*50]
      config.apps.each do |app, environments|
        environments.keys.each do |environment|
          name = "#{app}:#{environment}"
          server = environments[environment]['server']
          host = server ? server['host'] : 'localhost'
          puts "%-30s | %-50s" % [name, host]
        end
      end
    end

    # db-sync dump beautysage:qa > ~/Desktop/somefile.dump
    def dump
      opts = parse_opts(:dump)
      config = get_config(opts)
      app = get_app(config, opts)

      Stream.new($stdout) << Command.new(app).dump
    end

    # db-sync restore beautysage:local < ~/Desktop/somefile.dump
    def restore
      opts = parse_opts(:restore)
      config = get_config(opts)
      app = get_app(config, opts)

      has_stdin = STDIN.fcntl(Fcntl::F_GETFL, 0) == 0

      if has_stdin
        Stream.new($stdin) | Command.new(app).restore
      else
        puts "No STDIN found!"
        exit 74
      end
    end

    def get_config(opts = {})
      if opts[:config]
        DbSync::Config.load!(opts[:config])
      else
        DbSync::Config.load_default!
      end
    end

    def get_app(config, opts)
      data = config.app(opts[:app])

      unless data.has_key?(opts[:environment])
        puts "Could not find environment '#{opts[:environment]}' for app '#{opts[:app]}'!"
        exit 1
      end

      data[opts[:environment]]
    end

    def help
      puts %{
        Options
        =======
        dump      Dump a database from a remote server to a file
        restore   Restore a database from a dumpfile
        init      Create a db-sync config file (default: ~/.db-sync.yml)
        list      List all applications and environments in your config
        version   db-sync version

        Add '-h' to any command to see their usage
      }.split($/).map(&:lstrip).join($/)
    end

    def parse_opts(cmd)
      opts = {
        app: nil,
        environment: nil
      }

      OptionParser.new do |o|
        case cmd
        when :dump
          o.banner = "Usage: #{File.basename($0)} #{cmd} [OPTIONS] APP:ENVIRONMENT > outfile.dump"
          o.define_head "Dump a database from a remote server to STDOUT"
        when :restore
          o.banner = "Usage: #{File.basename($0)} #{cmd} [OPTIONS] APP:ENVIRONMENT < infile.dump"
          o.define_head "Restore a database from STDIN"
        end

        o.on("-c", "--config FILENAME", "Path to db-sync config (default: ~/.db-sync.yml)") { |v| opts[:config] = v }
        o.parse!(argv)

        opts[:app] = app = argv.shift

        if app.to_s.include?(':')
          opts[:app], opts[:environment] = app.split(':')
        end

        if opts[:app].nil?
          $stderr.puts "Missing FROM server name!"
          puts o
          exit 1
        end

        if opts[:environment].nil?
          $stderr.puts "Missing FROM environment!"
          puts o
          exit 1
        end
      end

      opts
    end

  end
end
