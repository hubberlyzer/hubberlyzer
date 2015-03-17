# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hubberlyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "hubberlyzer"
  spec.version       = Hubberlyzer::VERSION
  spec.authors       = ["Steven Yue"]
  spec.email         = ["jincheker@gmail.com"]

  spec.summary       = %q{Githubber Analyzer}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/steventen/hubberlyzer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'typhoeus', "~> 0.7"
  spec.add_dependency 'nokogiri', "~> 1.6"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
