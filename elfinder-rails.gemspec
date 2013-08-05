$:.push File.expand_path("../lib", __FILE__)
require 'elfinder-rails/version'

Gem::Specification.new do |s|
  s.name = 'elfinder-rails'
  s.version = ElfinderRails::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = "2013-08-05"
  s.authors = ['Mark J. Titorenko']
  s.email = 'mark.titorenko@alces-software.com'
  s.homepage = 'http://github.com/alces-software/elfinder-rails'
  s.summary = %Q{elFinder web file manager for Ruby on Rails}
  s.description = %Q{elFinder web file manager for Ruby on Rails}
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.mkd',
  ]

  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.7')
  s.rubygems_version = '1.3.7'
  s.specification_version = 3

  if File.exist?(File.join(File.dirname(__FILE__),'.git'))  
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  end
  s.require_paths = ['lib']

  s.add_dependency 'activesupport'
  s.add_dependency 'actionpack'
  s.add_dependency 'json'
  s.add_dependency 'rack'
  s.add_dependency 'arriba'
  s.add_development_dependency 'geminabox'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'bueller', '0.0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
end

