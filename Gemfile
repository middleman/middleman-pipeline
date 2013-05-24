source "https://rubygems.org"

gem "middleman-core", :github => "middleman/middleman"

# Specify your gem's dependencies in middleman-syntax.gemspec
gemspec

# gem "rake",     "~> 10.0.3", :require => false
gem "yard",     "~> 0.8.0", :require => false

# Test tools
gem "cucumber", "~> 1.3.1"
gem "fivemat"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"

platforms :ruby do
  gem "redcarpet"
end

gem "sass"
gem "compass"
gem "coffee-script", "~> 2.2.0"
gem "execjs", "~> 1.4.0"

platforms :ruby do
  gem "therubyracer"
end

platforms :jruby do
  gem "therubyrhino"
end

# Code Quality
gem "cane", :platforms => [:mri_19, :mri_20], :require => false
