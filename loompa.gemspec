# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{loompa}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tracey Eubanks"]
  s.date = %q{2010-08-03}
  s.description = %q{Manage a fork pool}
  s.email = %q{traceye@pmamediagroup.com}
  s.extra_rdoc_files = ["lib/loompa.rb"]
  s.files = ["Rakefile", "lib/loompa.rb", "readme", "Manifest", "loompa.gemspec"]
  s.homepage = %q{http://github.com/pmamediagroup/loompa}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Loompa", "--main", "readme"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{loompa}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Manage a fork pool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
