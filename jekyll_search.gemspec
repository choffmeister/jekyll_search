# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll_search/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll_search"
  spec.version       = JekyllSearch::VERSION
  spec.authors       = ["Christian Hoffmeister"]
  spec.email         = ["mail@choffmeister.de"]
  spec.summary       = "An Elasticsearch full text search index generator for Jekyll."
  spec.description   = ""
  spec.homepage      = "https://github.com/choffmeister/jekyll_search"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2.0"

  spec.add_dependency "jekyll", ">= 2.5.0"
  spec.add_dependency "elasticsearch", "~> 1.0.6"
  spec.add_dependency "loofah", "~> 2.0.1"
end
