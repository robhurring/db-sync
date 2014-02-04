module DbSync
  class LocalCommand
    attr_reader :command

    def initialize(command)
      @command = command
    end

    def run
    end
  end
end