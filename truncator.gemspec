lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'truncator/version'

Gem::Specification.new do |spec|
  spec.name          = "truncator"
  spec.version       = Truncator::VERSION
  spec.authors       = ["freemanoid"]
  spec.email         = ["freemanoid321@gmail.com"]
  spec.description   = %q{url truncator}
  spec.summary       = %q{Truncate urls as much as possible}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.0.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13"
end
