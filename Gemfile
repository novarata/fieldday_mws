source "https://rubygems.org"

# Specify gem dependencies in ruby_omx.gemspec
gemspec

gem 'amazon-mws', github: 'aew/amazon-mws'
#gem 'amazon-mws', path: '~/Code/amazon-mws'

group :development do
  gem "shotgun"
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov'
  #gem 'fakeredis', :require => "fakeredis/rspec"
  gem 'database_cleaner'
  gem 'webmock'
end