require 'fcntl'

module DbSync
  class Stream
    def initialize(io)
      @io = io
    end

    def stdin?
      STDIN.fcntl(Fcntl::F_GETFL, 0) == 0
    end

    # write to command from STDIN
    def |(command)
      IO.popen(command, 'w') do |pipe|
        pipe.write @io.gets until @io.eof?
      end
    end

    # write from command to STDOUT
    def <<(command)
      @io.sync

      IO.popen(command) do |pipe|
        @io.puts pipe.gets until pipe.eof?
      end
    end
  end
end
