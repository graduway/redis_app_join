# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_app_join/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_app_join"
  spec.version       = RedisAppJoin::VERSION
  spec.authors       = ["Dmitry Polyakovsky"]
  spec.email         = ["dmitrypol@gmail.com"]

  spec.summary       = %q{Uses Redis to cache data for application-side joins.}
  spec.description   = %q{Uses Redis hashes to cache data for application-side joins instead of building internal own data structures.}
  spec.homepage      = "https://github.com/dmitrypol/redis_app_join"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  # =>
  spec.add_development_dependency 'mock_redis', '~> 0.17', '>= 0.17.0'
  # =>
  spec.add_runtime_dependency 'redis', '~> 3.3'
  spec.add_runtime_dependency 'redis-namespace', '~> 1.5'
  spec.add_runtime_dependency 'readthis', '~> 1.3', '>= 1.3.0'
end
