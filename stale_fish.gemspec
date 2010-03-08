# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{stale_fish}
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin Smestad"]
  s.date = %q{2010-03-08}
  s.email = %q{justin.smestad@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/stale_fish.rb",
     "lib/stale_fish/fixture.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/support/stale_fish.yml",
     "spec/support/test.yml",
     "spec/unit/fixture_spec.rb",
     "spec/unit/stale_fish_spec.rb",
     "stale_fish.gemspec"
  ]
  s.homepage = %q{http://github.com/jsmestad/stale_fish}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{keeps fixtures synchronized with sources to prevent outdated fixtures going undetected.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/unit/fixture_spec.rb",
     "spec/unit/stale_fish_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fakeweb>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<fakeweb>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<fakeweb>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end

