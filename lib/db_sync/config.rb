require 'yaml'

module DbSync
  class Config
    FILENAME = '.db-sync.yml'
    PATHS = ['~', '.']
    TEMPLATE = File.expand_path('../../templates/.db-sync.yml.example')

    class << self
      def load!
        config_file = nil

        PATHS.each do |path|
          filename = File.expand_path(File.join(path, FILENAME))
          puts filename
          if File.exists?(filename)
            config_file = filename
          end
        end

        if config_file.nil?
          help
        else
          new(config_file)
        end
      end

      def init(path)

      end

      def help
        puts "Could not find config file in ~/.db-config.yml or ./.db-config.yml"
        puts "To create a config file run: #{File.basename($0)} init [PATH]"
        exit 1
      end
    end

    attr_reader :file

    def initialize(file)
      @file = file
      @data = YAML.load_file(file)
    end
  end
end