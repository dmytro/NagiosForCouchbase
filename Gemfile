source 'http://rubygems.org'

gem 'rest-client'
gem 'json'
gem 'sinatra', '>= 1.3.1'
gem 'rake'
# for Hash.extract!
gem 'activesupport'

#  Active_Model required for this:
# 'active_model/serialization'
# 'active_model/serializers/xml' # for Hash.to_xml
gem 'activemodel'

#
# RSpec modules should be in all environments - to be able to test prod config
# too
# 
gem 'rspec-core'
gem 'rspec-mocks'
gem 'rspec-expectations'

group :development do 
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'yard', "~> 0.8"
  gem "growl", "~> 1.0.3"
  gem "guard-brakeman", "~> 0.5.0"
  gem "guard-rspec", "~> 1.2.1"
  gem 'sinatra-contrib', '>= 1.3.1'
  platforms :mri do 
    gem 'redcarpet' # redcarpet fails in jruby
  end
end
