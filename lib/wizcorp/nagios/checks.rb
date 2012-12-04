module Wizcorp
  module Nagios

    class Checks

      # Reuse Couchbase API connections
      @@connections = { }

      def self.connections
        @@connections
      end

      # Creates an instance of an object. Object's atttibute
      # !@connection is an instance of Wizcorp::Couchbase::* object,
      # that connects to Couchbase RESTful API and retrieves status
      # information.
      #
      # @param [String, Symbol] key Couchbase variable. See
      #     config/checks.yml file for details.
      # 
      # @param [Hash] hash Connection Hash for Couchbase
      #     connection. See {Wizcorp::Couchbase::Connection#new}
      #     Options below are required, all other Hash attributes
      #     depend on the actual class constructor.
      #
      # @option hash [String] :hostname Couchbase server for service
      #     checks
      #
      # @option hash [Boolean] :reuse_connection Set to +false+ if you
      #     don't want to reuse connections for this service check. By
      #     default connections cached, and for several keys, data
      #     from single HTTP request are reused.
      #
      def initialize key,  hash={ }
        @key = CHECKS[key].merge(:name => key.to_sym)

        klass = [@key[:namespace],@key[:class]].join('::').to_class

        @hostname = hash[:hostname]
        
        if hash[:reuse_connection] == false
          @connection = klass.new(hash) 
        else
          @connection = @@connections[hash] || klass.new(hash) # Reuse connection
          @@connections[hash] = @connection
        end

      end

      attr_accessor :connection, :hostname
      attr_accessor :key

      # Check values obtained for the key from HTTP with configured
      # RAG status values. 
      # 
      # == Flow (see source)
      #
      # * (1) Get whole hash from HTTP
      #
      # * (2) Apply method to this hash. Method should exist, it is
      #   provided by method_missing, calculate sum of all values
      #   (TODO: add sum or avg parameter)
      #   Calculate function for the array.
      #
      # * (3) Start from Green and propagate to Red. Red is the most
      #   significant and checked at the end, overwriting previous.
      #
      # * (4) Compare obtained value with RAG configuration values using
      #   comparison operator in the configuration hash. 
      #
      def rag
        rag = -1 # Undefined by default

        connection.get # 1

        res = connection.send(@key[:name]).send(@key[:function].to_sym) # 2
        
        thresholds = @key[:rag].reverse # 3

        thresholds.each_index do |idx| # 4
          val = thresholds[idx]
          rag = idx if res.send(@key[:operator].to_sym, val)
        end

        { 
          :host_name => hostname,
          :plugin_output => res, 
          :return_code => rag, 
          # TODO - make it cleaner and DRY
          :service_description => "#{@key[:bucket]}:#{@key[:name]}"
        }
      end



    end
  end
end



# ["ep_tap_replica_count",
#  "ep_tap_rebalance_count",
#  "ep_tap_user_count",
#  "ep_tap_total_count",
#  "ep_tap_replica_qlen",
#  "ep_tap_rebalance_qlen",
#  "ep_tap_user_qlen",
#  "ep_tap_total_qlen",
#  "ep_tap_replica_queue_drain",
#  "ep_tap_rebalance_queue_drain",
#  "ep_tap_user_queue_drain",
#  "ep_tap_total_queue_drain",
#  "ep_tap_replica_queue_backoff",
#  "ep_tap_rebalance_queue_backoff",
#  "ep_tap_user_queue_backoff",
#  "ep_tap_total_queue_backoff",
#  "ep_tap_replica_queue_backfillremaining",
#  "ep_tap_rebalance_queue_backfillremaining",
#  "ep_tap_user_queue_backfillremaining",
#  "ep_tap_total_queue_backfillremaining",
#  "ep_tap_replica_queue_itemondisk",
#  "ep_tap_rebalance_queue_itemondisk",
#  "ep_tap_user_queue_itemondisk",
#  "ep_tap_total_queue_itemondisk"]
