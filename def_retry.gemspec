# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'def_retry/version'

Gem::Specification.new do |spec|
  spec.name          = "def_retry"
  spec.version       = DefRetry::VERSION
  spec.authors       = ["Diego Salazar"]
  spec.email         = ["diego@greyrobot.com"]
  spec.summary       = %q{The Retry Pattern in a gem.}
  spec.description   = %q{Allows you to define methods that will retry on exception or declare blocks of code with retry.}
  spec.homepage      = "https://github.com/DiegoSalazar/DefRetry"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"
end
