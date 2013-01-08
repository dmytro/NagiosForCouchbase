
root = File.dirname(File.dirname(__FILE__))

APP = { 
  :root => root,
  :config => "#{root}/config",
  :lib => "#{root}/lib"
}

APP.merge! YAML.load_file("#{APP[:config]}/environment.yml")

APP[:buckets] = if APP[:buckets][:list]
                  APP[:buckets][:list]
                else
                  Wizcorp::Couchbase::Buckets.list  :hostname => APP[:buckets][:source]
                end

# APP[:bucket_types] = Wizcorp::Couchbase::Buckets.types  :hostname => APP[:buckets][:source]

#
# Configuration for Nagios checks
#
CHECKS = YAML.load_file("#{APP[:config]}/checks.yml")['checks']

#
# Set values for Nagira installation and init.d file parsing
#
require_relative '../lib/nagira/config/install'
Nagira::INSTALL.merge!({
  :run_as => APP[:run_as],
  :log => APP[:log],
  :rvm => APP[:rvm]
})
