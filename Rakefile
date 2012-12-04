
require 'yaml'
require 'erb'
require_relative 'lib/couchbase'

desc "Setup application"
task :all => ["nagira:config:all"]


namespace :nagira do
  load 'lib/nagira/Rakefile'
end

namespace :client do 
  namespace :config do 
    
    desc "Create config for Nagios"
    task :generate do
      @hosts   = Wizcorp::Nagios::Hostgroup.new(
                                                :hostname => APP[:nagios][:api][:hostname]
                                                ).hosts(::APP[:nagios][:hostgroups])

      @checks = CHECKS.keys

      @buckets = APP[:buckets]

      @hostgroups = APP[:nagios][:hostgroups]
      puts ERB.new(File.read(File.join(APP[:config], APP[:nagios][:erb]))).result(binding)
    end
  end
end
