# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-pipeline/version"

Gem::Specification.new do |s|
  s.name        = "middleman-pipeline"
  s.version     = Middleman::Pipeline::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["me@tdreyno.com"]
  s.homepage    = "https://github.com/middleman/middleman-pipeline"
  s.summary     = %q{Rake::Pipeline support for Middleman}
  s.description = %q{Rake::Pipeline support for Middleman}

  s.rubyforge_project = "middleman-pipeline"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency("middleman-core", "~> 3.1.0.rc")
  s.add_dependency("rake-pipeline")
  s.add_dependency("rake-pipeline-web-filters")
end