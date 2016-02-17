# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_refactor/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_refactor"
  spec.version       = RailsRefactor::VERSION
  spec.authors       = ["Nick Dowse"]
  spec.email         = ["nm.dowse@gmail.com"]
  spec.description   = %q{Rename rails models}
  spec.summary       = %q{Rename rails models}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "spork"
  spec.add_development_dependency 'rails', '~> 3.2.18'

end
