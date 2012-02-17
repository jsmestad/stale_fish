$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{stale_fish}
  s.version = "1.3.2"
  s.authors = ["Justin Smestad"]
  s.date = %q{2012-02-16}
  s.email = %q{justin.smestad@gmail.com}
  s.homepage = %q{https://github.com/jsmestad/stale_fish}
  s.summary = "Stub HTTP responses"
  s.description = "Stub HTTP responses"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency(%q<fakeweb>, [">= 0"])
  s.add_dependency(%q<activesupport>, [">= 0"])
end

