# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sfcsfs', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["ymrl"]
  gem.email         = ["ymrl@ymrl.net"]
  gem.description   = %q{SFC-SFS Scraping Library}
  gem.summary       = %q{SFC-SFS Scraping Library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sfcsfs"
  gem.require_paths = ["lib"]
  gem.version       = SFCSFS::VERSION
  gem.add_dependency('nokogiri','~> 1.5.5')
  gem.add_dependency('addressable','~> 2.2.8')
  gem.add_dependency('pit')
  gem.add_dependency('sfc-room')
  gem.add_dependency('args_parser')
  gem.add_development_dependency('rspec', '~> 2.10.0')
  gem.add_development_dependency('rake')
end
