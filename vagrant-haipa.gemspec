# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-haipa/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-haipa"
  gem.version       = VagrantPlugins::Haipa::VERSION
  gem.authors       = ["Frank Wagner"]
  gem.email         = ["info@contiva.com"]
  gem.description   = %q{Enables Vagrant to manage Hyper-V with Haipa}
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "faraday", ">= 0.8.6"
  gem.add_dependency "json"
  gem.add_dependency "log4r"
end
