
root = File.dirname(File.dirname(__FILE__))

APP = { 
  :root => root,
  :config => "#{root}/config",
  :lib => "#{root}/lib"
}

APP.merge! YAML.load_file("#{APP[:config]}/environment.yml")
 
#
# Configuration for Nagios checks
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
