# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'identity/importer/version'

Gem::Specification.new do |spec|
  spec.name          = "identity-importer"
  spec.version       = Identity::Importer::VERSION
  spec.authors       = ["Hiemanshu Sharma"]
  spec.email         = ["hiemanshu@gmail.com"]

  spec.summary       = "Import data from CiviCRM to Identity"
  spec.homepage      = "https://github.com/the-open/identity-importer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
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

  spec.add_runtime_dependency "mysql2", "~> 0.3.1"
  spec.add_runtime_dependency "activerecord-import", "~> 0.15.0"
end
