# @title Installation and Configuration

Installation
===========

* Clone repo


      git clone --recursive https://github.com/NagiosForCouchbase.git


* Install startup file for Nagira REST API. Execute rake task from the top level of your installation directory.  Please note, first task below (`app:configure`) combines two following. 

  Nagira's init.d start file is created from ERB template and takes into account current installation directory, if you decide to change location of application in the future, re-run the task from the new location.
  
  Nagira directory must be accessible to the UNIX user running Nagira appliaction (usually `nagios`).

    rake app:configure           # Create Nagira configuration files
    rake app:nagira:init_d       # Install /etc/init.d startup file for Nagira
    rake app:nagira:service      # Start Nagira API service

Configuration 
====================

Nagira configuration
----------------------

Please refer to {http://dmytro.github.com/nagira Nagira documentation } regarding configuration of Nagira API. 

Although you'd probably need to change Nagira configuration only if you have non-standard Nagios installation.

NFC configuration
----------------------

All configuration files are in `./config` directory.

* `environment.rb` - Ruby code for loading necessary configurations
* `environment.yml` - YAML configuration for Application environment: paths', hostnames, ports, etc.
* `checks.yml` - Nagios service checks configuration.


### Nagios checks configuration


#### Description of the format


For clarification regarding format of the attributes, refer to defaults section. All configuration should adhere to the same syntax.

##### Colons (:) 


Attributes should have colons at both ends(i.e. `:namespace:`, `:class:`) Trailing colon is left/right side separator in YAML syntax. Leading colon specifies that this is a Symbol in Ruby terms.

Values for attributes `:function`, `:operator` also must have leading colons. These are Ruby method names, i.e. symbols.

##### Override

Import defaults by including `'<<: *default'`, see Example below.

Any default attribute can be overwritten. 

##### Attributes

* key (for example `:ep_tap_replica_queue_backfillremaining:`) is a Ruby method name. In a class defined by `:namespace:`, `:class:` pair, must exist or should be provided by `method_missing` method.

* `:namespace:` and `:class:` - Ruby module hierarchy, together with class define Ruby class that reads Couchbase data from REST.

* `:function:` - name of reduce type function (Array class method) for array pre-processing (for example, :sum or :avg) Function can be any Array method, producing single value. See ./lib/array.rb for the implemented ones.

* `:operator:` - comparison operator for evaluating RAG checks (for example `ep_tap_replica_queue_backfillremaining > 20`). Operator is Numeric method name, syntax is: `':>'`, `':=='`, `':!='`, etc. This can be any operator or method returning Boolean.

* `:rag:` - three element array of values to compare to [Red, Amber,
    Green], order is important.

#### Example

````yaml

default: &default
  :namespace: Wizcorp::Couchbase
  :class: BucketStats
  :function: :none 
  :operator: :>
  :rag: [0,0,0]  # order Red, Amber, Green

:ep_tap_replica_queue_backfillremaining:
   <<: *default
   :function: :sum
   :rag:  [-20, 10, -1]
   
```
