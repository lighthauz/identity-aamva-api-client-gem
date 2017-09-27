# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aamva/version"

Gem::Specification.new do |s|
  s.name = %q{aamva}
  s.version = AAMVA::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Zach Margolis <zachary.margolis@gsa.gov>"]
  s.email = %q{zachary.margolis@gsa.gov}
  s.homepage = %q{http://github.com/18F/identity-aamva-api-client-gem}
  s.summary = %q{AAMVA API client}
  s.description = %q{AAMVA API client for Ruby}
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.files = Dir.glob("app/**/*") + Dir.glob("lib/**/*") + [
     "LICENSE.md",
     "README.md",
     "Gemfile",
     "aamva-api-client.gemspec"
  ]
  s.license = "LICENSE"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('dotenv')
  s.add_dependency('savon', '~> 2.11.1')
  # s.add_dependency('activesupport')
  # s.add_dependency('gyoku')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('pry-byebug')
end
