module Wizcorp
  module Couchbase

    class Buckets < Connection

      def initialize params={ }
        super params
        @resource = "#{@connection[:pool]}/buckets"
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
