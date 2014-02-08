# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = %q{refinerycms-admin-search}
  s.version           = %q{1.0.0}
  s.description       = %q{An extension for support fulltext search in RefineryCMS Administration}
  s.summary           = %q{Refinery CMS Admin Search plugin}
  s.email             = %q{nospam.keram@gmail.com}
  s.homepage          = %q{http://github.com/keram/refinerycms-admin-search}
  s.authors           = ['Marek Laboš']
  s.license           = %q{MIT}
  s.require_paths     = %w(lib)

  s.files             = `git ls-files -- app/* lib/*`.split("\n")

  s.add_dependency    'refinerycms-core',     '~> 2.718.0.dev'
  s.add_dependency    'decorators',           '~> 1.0.3'
end
