Gem::Specification.new do |s|
  s.name        = "fieldday_mws"
  s.version     = "0.0.1"
  s.date        = %q{2013-04-14}
  s.summary     = "Mountable engine for Amazon MWS services to FieldDay"
  s.authors     = ['A. Edward Wible']
  s.email       = ["aewible@gmail.com"]

  s.files = Dir["lib/**/*"] + Dir["spec/**/*"] + ["README.md"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "sinatra"
  s.add_dependency "sinatra-contrib"
  s.add_dependency "activerecord", '4.0.0.beta1'  
  s.add_dependency "puma"
  s.add_dependency "haml"
  s.add_dependency "redis-store"
  s.add_dependency "sidekiq"
  s.add_dependency "sidekiq-throttler"
  s.add_dependency "rest-client"
  s.add_dependency "typhoeus"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
end
