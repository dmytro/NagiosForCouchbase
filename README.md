
Couchbase Nagios Monitoring
===========================

Note for the documentation: These documents are more readable in parsed YARD form (links and images are working). Formatted YARD documentatioin can be found at: http://dmytro.github.com/NagiosForCouchbase


Purspose
===========

This is a monitoring framework for monitoring Couchbase with Nagios. It relies on native RESTful API of Couchbase and RESTful API for Nagios - Nagira.

System architecture
----------------------
![Monitoring Work Flow](images/architecture.png)


Work-flow diagram
----------------------

![Monitoring Work Flow](images/workflow.png)

Configuration
--------------

See {file:CONFIGURATION}

Directory layout
======================

````
├── config
│   ├── checks.yml
│   ├── environment.rb
│   └── environment.yml
└── lib
    ├── couchbase.rb
    ├── extensions.rb
    └── wizcorp
        ├── couchbase
        │   ├── bucket_stats.rb
        │   ├── buckets.rb
        │   ├── connection.rb
        │   └── counters.rb
        └── nagios
            ├── api.rb
            ├── checks.rb
            └── runner.rb
````

