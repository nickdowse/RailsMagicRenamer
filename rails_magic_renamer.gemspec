# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_magic_renamer/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_magic_renamer"
  spec.version       = RailsMagicRenamer::VERSION
  spec.authors       = ["Nick Dowse"]
  spec.email         = ["nm.dowse@gmail.com"]
  spec.description   = %q{Rename rails models, magically. Pre-release, not production ready}
  spec.summary       = %q{Rename rails models, magically}
  spec.homepage      = "https://github.com/nickdowse/RailsMagicRenamer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-filemagic"


  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "spork"
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'factory_girl_rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rails', '4.0.13'

end
