module Wizcorp
  module Couchbase
    
    # Note: aother classes (with more code then here) are in their
    # respective files

    # Get counter
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

    
  end # module Couchbase
end
