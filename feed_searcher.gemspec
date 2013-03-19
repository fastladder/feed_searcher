# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "feed_searcher/version"

Gem::Specification.new do |spec|
  spec.name          = "feed_searcher"
  spec.version       = FeedSearcher::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.description   = "FeedSearcher searches RSS feed URLs from the given URL."
  spec.summary       = "Search RSS feed URLs from the given URL"
  spec.homepage      = "https://github.com/r7kamura/feed_searcher"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", ">= 1.0.0"
  spec.add_dependency "nokogiri"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.13.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
