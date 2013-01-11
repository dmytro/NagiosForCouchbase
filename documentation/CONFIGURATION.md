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

Please refer to [Nagira documentation](http://dmytro.github.com/nagira) regarding configuration of Nagira API. 

Although you'd probably need to change Nagira configuration only if you have non-standard Nagios installation.

NFC configuration
----------------------

All configuration files are in `./config` directory.

* `environment.rb` - Ruby code for loading necessary configurations
* `environment.yml` - YAML configuration for Application environment: paths', hostnames, ports, etc.
* `checks.yml` - Nagios service checks configuration.


### Nagios checks configuration

#### RAG Threshold Check 


Checks performed by applying comparison operator to RAG threshold and data returned by Couchbase API. 

1. Before start result is set to undefined value, 
1. Then checks are applied in reverse order: Green, Amber, Red. 
1. Result status is updated only if check succeeds. So, Amber overwtrites Green, and Red overwrites Amber.

If no checks are succeded then returned value is `nil` (undefined). 

That means that threshold should be set in such way, that at least one of the checks be successful. For example: if you want to see alert in case `:ep_tmp_oom_errors:` is more than 0, you will need to set operator to `:>=` and `:rag` to [1,1,0]. 
`

#### Description of the format


For clarification regarding format of the attributes, refer to defaults section. All configuration should adhere to the same syntax.

##### Colons (:) 


Attributes should have colons at both ends(i.e. `:namespace:`, `:class:`) Trailing colon is left/right side separator in YAML syntax. Leading colon specifies that this is a Symbol in Ruby terms.

Values for attributes `:function`, `:operator` also must have leading colons. These are Ruby method names, i.e. symbols.

##### Special note about colons in lists

Operator specs allow for either single operator for all checks (eg. `:>`) or individual check for each of RAG thresholds: `[:>, :==, :>]`. Since this is a method name, and is a Symbol, it should be prepended with colon (`:`). 

In YAML syntax former does not constitute any problem, following is OK:

    :operator: :>
    
However, for lists, inline format is not acceptable, so for checks block format with hyphen-space should be used:    

* This is OK:    

        :operator:
           - :>
           - :=
           - :>

* But this does not work:

        :operator: [ :<, :> , :== ]
    

##### Override

Import defaults by including `'<<: *default'`, see Example below.

Any default attribute can be overwritten. 

##### Attributes

* key (for example `:ep_tap_replica_queue_backfillremaining:`) is a Ruby method name. In a class defined by `:namespace:`, `:class:` pair, should exist in specified class (defined explicitly) or provided by `method_missing` method.

* `:namespace:` and `:class:` - Ruby module hierarchy, together with class define Ruby class that reads Couchbase data from REST.

* `:function:` - name of reduce type function (Array instance method) for array pre-processing (for example, `:sum` or `:avg`) Function can be any Array method, producing single value. See `./lib/array.rb` for the implemented ones. Function `:none` dos not perform any preprocessing, it simply returns unmodified object. This is can be used when data (for example Boolean) are simply passed to comparison operator(s).

* `:rag:` - three element array of values to compare to [Red, Amber, Green], order is important.

  Example:
  
  ```
    :ep_tap_total_queue_drain:
    :rag: [100,80,-1]
   ```

* `:operator:` - comparison operator for evaluating RAG checks (for example `ep_tap_replica_queue_backfillremaining > 20`). Operator is Numeric method name, syntax is: `':>'`, `':=='`, `':!='`, etc. This can be any operator or method returning Boolean. Operator can be also 3-element array of operators if comparisons for different levens of RAG's are requried.


* `:only_if:` - by default configuration is applied to all buckets. However there are some metrics that do not exist in both bucket types (memcache and membase). In this case it is possible to override default and apply it only to the specified bucket type. 

  Example: 

```yaml  
        :ep_tap_replica_queue_itemondisk:
        :only_if: membase
```    


### Example configuration

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
