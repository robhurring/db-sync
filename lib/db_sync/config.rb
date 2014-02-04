require 'yaml'

module DbSync
  class Config
    DEFAULT_CONFIG = '~/.db-sync.yml'
    TEMPLATE = File.expand_path('../../../templates/.db-sync.yml.example', __FILE__)

    class << self
      def init!(filename = nil)
        filename ||= DEFAULT_CONFIG
        filename = File.expand_path(filename)

        if Dir.exists?(filename)
          filename = File.join(filename, '.db-sync.yml')
        end

        if File.exists?(filename)
          puts "File already exists at this location!"
          help
        else
          template = File.read(TEMPLATE)

          File.open(filename, 'w+') do |f|
            f << template
          end

          puts "Config file created at: #{filename}"
          exit 0
        end
      end

      def load!(filename)
        if File.exists?(filename)
          new(filename)
        else
          help
        end
      end

      def load_default!
        load!(File.expand_path(DEFAULT_CONFIG))
      end

      def help
        puts "No config file could be found!"
        puts
        puts "To create a config file run: #{File.basename($0)} init [PATH]"
        puts "If you would like to use a custom config file, see the OPTIONS provided"
        puts "by the command you are trying to run."
        puts
        exit 1
      end
    end

    attr_reader :file, :data

    def initialize(file)
      @file = file

      if File.exists?(file)
        @data = YAML.load_file(file)
      else
        self.class.help
      end
    end

    def app(name, env = nil)
      @data['apps'][name]
    end
  end
end