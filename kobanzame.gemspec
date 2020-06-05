
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kobanzame/version"

Gem::Specification.new do |spec|
  spec.name          = "kobanzame"
  spec.version       = Kobanzame::VERSION
  spec.authors       = ["inokappa"]
  spec.email         = ["inokara@gmail.com"]
  spec.summary       = %q{kobanzame collects resources for ecs task.}
  spec.description   = %q{kobanzame collects resources for ecs task.}
  spec.homepage      = "https://github.com/inokappa/kobanzame"

  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'aws-sdk-cloudwatchlogs'
  spec.add_dependency 'serverengine'
end
