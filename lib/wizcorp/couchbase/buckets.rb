module Wizcorp
  module Couchbase

    class Buckets < Connection

      def initialize params={ }
        super params
        @resource = "#{@connection[:pool]}/buckets"
      end

      # Return names of all buckets on the server
      #
      # @param [String, Symbol] type Type of the bucket (membase or
      #     memcached), if nil rerurn list of all buckets regardless of
      #     type
      def self.list params={ }, type = nil
        server = self.new(params)
        server.get
        if type
          server.data.map{ |x| x['name'] if x['bucketType'] == type }.compact
        else
          server.data.map { |x| x['name']}
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
