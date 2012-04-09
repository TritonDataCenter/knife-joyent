# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = "knife-joyent"
  s.version = "0.1"
  s.has_rdoc = true
  s.authors = ["Kevin Chan"]
  s.email = ["kevin@joyent.com"]
  s.homepage = "http://wiki.opscode.com/display/chef"
  s.summary = "Joyent CloudAPI Support for Chef's Knife Command"
  s.description = s.summary
  s.extra_rdoc_files = ["README.md", "LICENSE" ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "fog", "1.3.1"
  s.require_paths = ["lib"]

end
