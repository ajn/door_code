# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "door_code"
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Fulcher"]
  s.email       = ["mike@plan9design.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Restrict access to your site with a 5-digit PIN code}
  s.description = %q{Rack middleware which requires that visitors to the site enter a 5-digit PIN code to gain access. 
                      Can (optionally) be applied only to specified URLs (eg to target only a development/staging server).}

  s.rubyforge_project = "door_code"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Runtime
  s.add_runtime_dependency 'rack'
end
