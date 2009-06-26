# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{stale_popcorn}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin Smestad"]
  s.date = %q{2009-06-26}
  s.email = %q{justin.smestad@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/stale_popcorn.rb",
     "spec/fixtures/google.html",
     "spec/fixtures/malformed_stale_popcorn.yml",
     "spec/fixtures/stale_popcorn.yml",
     "spec/fixtures/stale_popcorn.yml.stupid",
     "spec/fixtures/yahoo.html",
     "spec/spec_helper.rb",
     "spec/stale_popcorn_spec.rb",
     "tmp/.gitignore"
  ]
  s.homepage = %q{http://github.com/jsmestad/stale_popcorn}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{keeps fixtures synchronized with sources to prevent outdated fixtures going undetected.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/stale_popcorn_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fakeweb>, [">= 1.2.4"])
      s.add_runtime_dependency(%q<rio>, [">= 0.4.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.2"])
    else
      s.add_dependency(%q<fakeweb>, [">= 1.2.4"])
      s.add_dependency(%q<rio>, [">= 0.4.2"])
      s.add_dependency(%q<activesupport>, [">= 2.1.2"])
    end
  else
    s.add_dependency(%q<fakeweb>, [">= 1.2.4"])
    s.add_dependency(%q<rio>, [">= 0.4.2"])
    s.add_dependency(%q<activesupport>, [">= 2.1.2"])
  end
end
