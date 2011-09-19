# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{elfinder-rails}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.date = %q{2011-09-19}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.mkd"
  ]
  s.files = [
    "app/controllers/elfinder_controller.rb",
    "config/application.rb",
    "config/boot.rb",
    "config/routes.rb",
    "lib/elfinder-rails.rb",
    "lib/elfinder-rails/engine.rb"
  ]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{elFinder web file manager for Ruby on Rails}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<actionpack>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<arriba>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.1.0"])
      s.add_dependency(%q<actionpack>, [">= 3.1.0"])
      s.add_dependency(%q<arriba>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.1.0"])
    s.add_dependency(%q<actionpack>, [">= 3.1.0"])
    s.add_dependency(%q<arriba>, [">= 0"])
  end
end
