module Wizcorp
  module Couchbase

    class Buckets < Connection

      def initialize params={ }
        super params
        @resource = "#{@connection[:pool]}/buckets"
      end

      ##
      # Return list of all bucket types
      def self.types params={ }
        self.by_type(params).keys
      end


      ##
      # Return list of all buckets as hash, where key is bucket type
      # 
      def self.by_type params={ }
        data, ret = self.new(params).get, { }

        types = data.map{ |x| x['bucketType'] }.uniq.compact
        types.each do |t|
          ret[t] = data.map{ |x| x['name'] if x['bucketType'] == t }.compact
        end
        ret
      end

      # Return names of all buckets on the server
      #
      # @param [String, Symbol] type Type of the bucket (membase or
      #     memcached), if nil rerurn list of all buckets regardless of
      #     type
      def self.list params={ }, type = nil
        if type
          self.by_type(params)[type]
        else
          self.by_type(params).values.flatten
        end
      end

    # Buckets interface is different from ones above: for single
    # bucket it should return Hash, while for multiple: Array. 
    #
    # Missing_method should work with Hash data, for Array: TBD
      def get bucket=nil
        if bucket
          super [@resource , bucket].join('/') 
        else 
          super
        end
      end
      
    end # class Buckets

  end
end
