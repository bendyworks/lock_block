# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lock_block/version'

Gem::Specification.new do |gem|
  gem.name                  = "lock_block"
  gem.version               = LockBlock::VERSION
  gem.authors               = ["Joe Nelson"]
  gem.email                 = ["cred+github@begriffs.com"]
  gem.description           = %q{Mark code blocks important, monitor them}
  gem.summary               = %q{Provides command-line tool to annotate and check blocks of code}
  gem.homepage              = "https://github.com/begriffs/lock_block"

  gem.files                 = `git ls-files`.split($/)
  gem.executables           = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files            = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths         = ["lib"]
  gem.required_ruby_version = '>= 1.9'

  gem.add_dependency 'trollop', '~> 2.0'
end
