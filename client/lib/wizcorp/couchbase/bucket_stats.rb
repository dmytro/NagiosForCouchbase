module Wizcorp
  module Couchbase

    # 
    class BucketStats < Connection

      # Retrieves stats for single bucket only.
      def initialize params={ }
        raise "#{self.class} constructor needs :bucket argument" unless params.has_key? :bucket
        bucket = params[:bucket]
        super params
        @resource = "#{@connection[:pool]}/buckets/#{bucket}/stats"
      end

      # Custom method_missing method to access structure in
      # a.op(:samples).keys (see below).
      #
      # == Example
      #
      #     >> a =  Wizcorp::Couchbase::BucketStats.new('default', :hostname => 'cbm1')
      #     >> a.hit_ratio
      #
      #     => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      #         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      #         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      #         0, 0, 0, 0, 0, 0]
      def method_missing sym
        get if data == { }
        sym = sym.to_s
        
        if data['op']['samples'].has_key?(sym)
          return data['op']['samples'][sym]
        else
          super sym
        end

          
      end



    end #class BucketStats

  end
end

      # This is example of the data in 'op' Hash key:
      # 

      # >> a.op.keys
      # => ["samples", "samplesCount", "isPersistent", "lastTStamp", "interval"]

      # >> a.op(:samples).keys => ["hit_ratio", "ep_cache_miss_rate",
      # "ep_resident_items_rate", "vb_avg_active_queue_age",
      # "vb_avg_replica_queue_age", "vb_avg_pending_queue_age",
      # "vb_avg_total_queue_age", "vb_active_resident_items_ratio",
      # "vb_replica_resident_items_ratio",
      # "vb_pending_resident_items_ratio", "avg_disk_update_time",
      # "avg_disk_commit_time", "avg_bg_wait_time", "bg_wait_count",
      # "bg_wait_total", "bytes_read", "bytes_written", "cas_badval",
      # "cas_hits", "cas_misses", "cmd_get", "cmd_set",
      # "curr_connections", "curr_items", "curr_items_tot",
      # "decr_hits", "decr_misses", "delete_hits", "delete_misses",
      # "disk_commit_count", "disk_commit_total", "disk_update_count",
      # "disk_update_total", "disk_write_queue", "ep_bg_fetched",
      # "ep_diskqueue_drain", "ep_diskqueue_fill",
      # "ep_diskqueue_items", "ep_flusher_todo", "ep_ht_memory",
      # "ep_item_commit_failed", "ep_kv_size", "ep_max_data_size",
      # "ep_mem_high_wat", "ep_mem_low_wat", "ep_num_non_resident",
      # "ep_num_value_ejects", "ep_oom_errors", "ep_ops_create",
      # "ep_ops_update", "ep_overhead", "ep_queue_size",
      # "ep_tap_rebalance_count", "ep_tap_rebalance_qlen",
      # "ep_tap_rebalance_queue_backfillremaining",
      # "ep_tap_rebalance_queue_backoff",
      # "ep_tap_rebalance_queue_drain", "ep_tap_rebalance_queue_fill",
      # "ep_tap_rebalance_queue_itemondisk",
      # "ep_tap_rebalance_total_backlog_size", "ep_tap_replica_count",
      # "ep_tap_replica_qlen",
      # "ep_tap_replica_queue_backfillremaining",
      # "ep_tap_replica_queue_backoff", "ep_tap_replica_queue_drain",
      # "ep_tap_replica_queue_fill",
      # "ep_tap_replica_queue_itemondisk",
      # "ep_tap_replica_total_backlog_size", "ep_tap_total_count",
      # "ep_tap_total_qlen", "ep_tap_total_queue_backfillremaining",
      # "ep_tap_total_queue_backoff", "ep_tap_total_queue_drain",
      # "ep_tap_total_queue_fill", "ep_tap_total_queue_itemondisk",
      # "ep_tap_total_total_backlog_size", "ep_tap_user_count",
      # "ep_tap_user_qlen", "ep_tap_user_queue_backfillremaining",
      # "ep_tap_user_queue_backoff", "ep_tap_user_queue_drain",
      # "ep_tap_user_queue_fill", "ep_tap_user_queue_itemondisk",
      # "ep_tap_user_total_backlog_size", "ep_tmp_oom_errors",
      # "ep_vb_total", "evictions", "get_hits", "get_misses",
      # "incr_hits", "incr_misses", "mem_used", "misses", "ops",
      # "timestamp", "vb_active_eject", "vb_active_ht_memory",
      # "vb_active_itm_memory", "vb_active_num",
      # "vb_active_num_non_resident", "vb_active_ops_create",
      # "vb_active_ops_update", "vb_active_queue_age",
      # "vb_active_queue_drain", "vb_active_queue_fill",
      # "vb_active_queue_size", "vb_pending_curr_items",
      # "vb_pending_eject", "vb_pending_ht_memory",
      # "vb_pending_itm_memory", "vb_pending_num",
      # "vb_pending_num_non_resident", "vb_pending_ops_create",
      # "vb_pending_ops_update", "vb_pending_queue_age",
      # "vb_pending_queue_drain", "vb_pending_queue_fill",
      # "vb_pending_queue_size", "vb_replica_curr_items",
      # "vb_replica_eject", "vb_replica_ht_memory",
      # "vb_replica_itm_memory", "vb_replica_num",
      # "vb_replica_num_non_resident", "vb_replica_ops_create",
      # "vb_replica_ops_update", "vb_replica_queue_age",
      # "vb_replica_queue_drain", "vb_replica_queue_fill",
      # "vb_replica_queue_size", "vb_total_queue_age"] >>

