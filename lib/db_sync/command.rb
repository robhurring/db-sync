module DbSync
  class Command
    def initialize(app)
      @app = app
    end

    def localhost?
      @app['server'].nil?
    end

    def dump
      if localhost?
        dump_command
      else
        auth = "%{user}@%{host}" % {
          user: @app['server']['user'],
          host: @app['server']['host']
        }

        %{ssh #{auth} -C "#{dump_command}"}
      end
    end

    def restore
      if localhost?
        restore_command
      else
        raise 'not implemented yet!'
      end
    end

    def pg_dump_command
      command = @app['commands'] && @app['commands']['pg_dump']
      command || 'pg_dump'
    end

    def pg_restore_command
      command = @app['commands'] && @app['commands']['pg_restore']
      command || 'pg_restore'
    end

    def db_cli_options
      db = @app['db']

      options = {
        username: '',
        host: '',
        password: '',
        database: db['database']
      }

      if host = db['host']
        options[:host] = %{-h #{host}}
      end

      if port = db['port']
        options[:port] = %{-p #{port}}
      end

      if username = db['username']
        options[:username] = %{-U #{username}}
      end

      if db['password']
        options[:password] = %{PGPASSWORD="#{db['password']}"}
      end

      options
    end

    def dump_command
      options = db_cli_options
      options.merge!(
        command: pg_dump_command,
        options: '-Fc --verbose --no-acl --no-owner',
      )

      command = "%{password} %{command} %{options} %{host} %{username} %{database}" % options
      command = command.squeeze(' ')
    end

    def restore_command
      options = db_cli_options
      options.merge!(
        command: pg_restore_command,
        options: '--verbose --clean --no-acl --no-owner',
      )

      command = "%{password} %{command} %{options} %{host} %{username} -d %{database}" % options
      command = command.squeeze(' ')
    end
  end
end