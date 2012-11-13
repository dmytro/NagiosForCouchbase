module Wizcorp
  module Nagios

    class Checks

      # @param [String, Symbol] key Configuration parameter from 
      def initialize key,  hash={ }
        key = key.to_sym
        @key = CONFIG[key].merge(:name => key)

        klass = [@key[:namespace],@key[:class]].join('::').to_class
        @connection = klass.new hash
      end

      attr_accessor :connection
      attr_accessor :key

      # Check values obtained for the key from HTTP with configured RAG status values
      #
      def rag
        rag = -1 # Undefined by default

        # Get whole hash from HTTP
        connection.get

        # Apply method to this hash. Method should exist, it is
        # provided by method_missing, calculate sum of all values
        # (TODO: add sum or avg parameter)
        res = connection.send(@key[:name]).send(@key[:function])

        # Compare obtained value with RAG configuration values using
        # comparison operator in the configuration hash. Start from
        # gree and propagate to Red. Red is the most significant and
        # checked at the end.
        
        thresholds = @key[:rag].reverse

        thresholds.each_index do |idx|
          val = thresholds[idx]

          rag = idx if res.send(@key[:operator], val)

        end

        { :plugin_output => res, :return_code => rag, :service_description => @key[:name]}
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
