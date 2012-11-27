
Couchbase Nagios Monitoring
===========================

Workflow diagram
======================

![Monitoring Work Flow](images/workflow.png)

Directory layout
======================

````
├── config
│   ├── checks.yml
│   ├── environment.rb
│   └── environment.yml
└── lib
    ├── couchbase.rb
    ├── extensions.rb
    └── wizcorp
        ├── couchbase
        │   ├── bucket_stats.rb
        │   ├── buckets.rb
        │   ├── connection.rb
        │   └── counters.rb
        └── nagios
            ├── api.rb
            ├── checks.rb
            └── runner.rb
````


Configuration files
====================

All configuration files are in `./config` directory.

* `environment.rb` - Ruby code for loading necessary configurations
* `environment.yml` - YAML configuration for Application environment: paths', hostnames, ports, etc.
* `checks.yml` - Nagios service checks configuration.


Nagios checks configuration
---------------------------

### Description of the format


For clarification regarding format of the attributes, refer to defaults section. All configuration should adhere to the same syntax.

#### Colons (:) 


Attributes should have colons at both ends(i.e. `:namespace:`, `:class:`) Trailing colon is left/right side separator in YAML syntax. Leading colon specifies that this is a Symbol in Ruby terms.

Values for attributes `:function`, `:operator` also must have leading colons. These are Ruby method names, i.e. symbols.

#### Override

Import defaults by including `'<<: *default'`, see Example below.

Any default attribute can be overriden. 

#### Attributes

* key (for example `:ep_tap_replica_queue_backfillremaining:`) is a Ruby method name. In a class defined by `:namespace:`, `:class:` pair, must exist or should be provided by `method_missing` method.

* `:namespace:` and `:class:` - Ruby module hierarchy, together with class define Ruby class that reads Couchbase data from REST.

* `:function:` - name of reduce type function (Array class method) for array pre-processing (for example, :sum or :avg) Function can be any Array method, producing single value. See ./lib/array.rb for the implemented ones.

* `:operator:` - comparison operator for eavluating RAG checks (for example `ep_tap_replica_queue_backfillremaining > 20`). Operator is Numeric method name, syntax is: `':>'`, `':=='`, `':!='`, etc. This can be any operator or method returning boolean.

* `:rag:` - three element array of values to compare to [Red, Amber,
    Green], order is important.

### Example

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
