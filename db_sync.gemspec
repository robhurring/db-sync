# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "db_sync"
  spec.version       = DbSync::VERSION
  spec.authors       = ["robhurring"]
  spec.email         = ["robhurring@gmail.com"]
  spec.summary       = %q{Handles pg_dump and pg_restore from a config file}
  spec.description   = %q{Allows dumping and restoring of databases from a config file}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
