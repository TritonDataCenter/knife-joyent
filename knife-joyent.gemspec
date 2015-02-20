# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'knife-joyent/version'

Gem::Specification.new do |s|
  s.name = "knife-joyent"
  s.version = KnifeJoyent::VERSION
  s.has_rdoc = true
  s.authors = ["Kevin Chan"]
  s.email = ["kevin@joyent.com"]
  s.homepage = "https://github.com/kevinykchan/knife-joyent"
  s.summary = "Joyent CloudAPI Support for Chef's Knife Command"
  s.description = s.summary
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency "fog", ">= 1.28.0"
  s.add_dependency "multi_json", "~> 1.7"
  s.add_dependency "joyent-cloud-pricing", ">= 1.1.0"
  s.add_dependency 'chef', '>= 11.16.2', '< 12.1'
  s.add_development_dependency 'rspec'

  s.require_paths = ["lib"]
end
