
root = File.dirname(File.dirname(__FILE__))

APP = { 
  :root => root,
  :config => "#{root}/config",
  :lib => "#{root}/lib"
}

APP.merge! YAML.load_file("#{APP[:config]}/environment.yml")
 
#
# Configuration for Nagios checks
CHECKS = YAML.load_file "#{APP[:config]}/checks.yml"
