# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ferenc/version'

Gem::Specification.new do |spec|
  spec.name          = "ferenc"
  spec.version       = Ferenc::VERSION
  spec.authors       = ["kayhide"]
  spec.email         = ["kayhide@gmail.com"]
  spec.summary       = %q{Create products from elements.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "http://github.com/kayhide/ferenc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_dependency "activesupport", "~> 4.1.0"
  spec.add_dependency "activemodel", "~> 4.1.0"
  spec.add_dependency "colorize"
end
