# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'national_bank_of_romania/version'

Gem::Specification.new do |gem|
  gem.name          = "national_bank_of_romania"
  gem.version       = NationalBankOfRomania::VERSION
  gem.authors       = ["Vlad Suciu"]
  gem.email         = ["suciu.vlad@gmail.com"]
  gem.description   = %q{This gem provides the ability to download the exchange rates from the National Bank of Romania and it is compatible with the money gem.}
  gem.summary       = %q{This gem provides the ability to download the exchange rates from the National Bank of Romania and it is compatible with the money gem.}
  gem.homepage      = ""

  gem.add_dependency "nokogiri", "~> 1.5.6"
  gem.add_dependency "money", "~> 5.0.0"

  gem.add_development_dependency "rspec", ">= 2.12.0"
  gem.add_development_dependency "rake"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
