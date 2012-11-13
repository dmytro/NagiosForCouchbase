module Wizcorp
  module Couchbase
    class Counters < Connection

      def initialize params={ }
        super params
        @resource = 'counters'
      end

    end # class Connection


    class Pool < Connection
      def initialize params={ }
        super params
        @resource = pool
      end
    end


    class Buckets < Connection

      def initialize params={ }
        super params
        @resource = "#{@connection[:pool]}/buckets"
      end


    # Buckets inteface is different from ones above: for single
    # bucket it should return Hash, while for multiple: Array. 
    #
    # Missing_method should work with Hash data, for Arra: TBD
      def get bucket=nil
        if bucket
          super [@resource , bucket].join('/') 
        else 
          super
        end
      end
      
    end # class Buckets

    class BucketStats < Connection

      # Retrieves stats for single bucket only.
      def initialize bucket, params={ }
        super params
        @resource = "#{@connection[:pool]}/buckets/#{bucket}/stats"

      end
    end
    
  end # module Couchbase
end
