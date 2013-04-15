Gem::Specification.new do |s|
  s.name        = "fieldday_mws"
  s.version     = "0.0.1"
  s.date        = %q{2013-04-14}
  s.summary     = "Mountable engine for Amazon MWS services to FieldDay"
  s.authors     = ['A. Edward Wible']
  s.email       = ["aewible@gmail.com"]

  s.files = Dir["lib/**/*"] + ["README.md"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "sinatra"
  s.add_dependency "sinatra-activerecord"
  s.add_dependency "pg"
  s.add_dependency "puma"
  s.add_dependency "haml"
end