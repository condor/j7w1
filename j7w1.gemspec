# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'j7w1/version'

Gem::Specification.new do |spec|
  spec.name          = "j7w1"
  spec.version       = J7W1::VERSION
  spec.authors       = ["condor"]
  spec.email         = ["condor1226@gmail.com"]
  spec.description   = %q{Mobile apps push client}
  spec.summary       = %q{Mobile apps push client}
  spec.homepage      = "https://github.com/condor/j7w1"
  spec.license       = "MIT"

  spec.files         = `git ls-files Gemfile LICENSE.txt README.md j7w1.gemspec lib spec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 1.17"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", ">= 4.0"
  spec.add_development_dependency 'simplecov'
end
