# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ucc/version"

Gem::Specification.new do |s|
  s.name        = "ucc"
  s.version     = Ucc::VERSION
  s.authors     = ["MOZGIII"]
  s.email       = ["mike-n@narod.ru"]
  s.homepage    = ""
  s.summary     = %q{Use just "ucc file" instead of "gcc -Wall file -o file".}
  s.description = %q{This gem makes it easy to compile small apps using gcc or g++, you even don't need a makefile!}

  s.rubyforge_project = "ucc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
