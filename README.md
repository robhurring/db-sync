# DbSync

Handles pg_dump and pg_restore from a common config file of servers and databases

## Installation

Or install it yourself as:

1. clone this repo
2. `rake build`
3. `rake install`

## Usage

`db-sync` requires a YAML file if your server configurations and passwords. To get started run the `db-sync init` call to create a blank template in `~/.db-sync.yml`. Edit this file and define your apps, as well as their environments and any other configuration you many need.

### Dumping from a remote server

Given you filled out your config with something like:

```
# define your apps and environments for syncing and pulling the database
apps:
  ecommerce:
    production:
      # make sure you can SSH to this server `ssh deploy@myapp.com` should work
      server:
        host: myapp.com
        user: deploy
      db:
        host: db.myapp.com
        database: ecommerce_production
        username: postgres
        password: somecrazypasswordinproduction
    local:
      db:
        database: ecommerce_development
        username: postgres
```

You can dump the production database to your Desktop by doing the following:

`db-sync dump ecommerce:production > ~/Desktop/production.dump`

This will build the necessary `pg_dump` commands and issue them over SSH and stream the data back to STDOUT.

### Restore your local database from a dumpfile

Given the above configuration, and your dumpfile is at `~/Desktop/production.dump` you can issue the following command to restore your local DB with the production data:

`db-sync restore ecommerce:local < ~/Desktop/production.dump`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
