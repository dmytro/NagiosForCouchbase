module Wizcorp
  module Couchbase

    # Class to establish connection and handle communication with
    # Couchbase server HTTP API.
    #
    # This is parent class for all others, they are inheric connection
    # setting from this class.
    #
    class Connection

      require 'net/http' 
      require 'json'
      require 'pp'

      def initialize connection={}
        # Set default values
        @connection = { 
          :hostname     => 'localhost',
          :port         => 8091,
          :pool         => 'default',
          :buckets      => ['default'],
          :ttl          => 60   # Interval in seconds for requesting
                                # data from HTTP, do not request more
                                # often than this
        }.merge(connection)

        c = @connection
        @uri = "http://#{c[:hostname]}:#{c[:port]}/pools/"

        @resource = nil
        @data = { }
        @ttl  =  @connection[:ttl]
        @last_update = 0
      end

      attr_accessor :uri
      attr_accessor :data
      attr_accessor :connection

      # Helper method to access @connection hash attribute
      def pool; connection[:pool] end

      # Helper method to access @connection hash attribute
      def buckets; connection[:buckets] end

      # Connect to API and get JSON hash from it.
      #
      # @param [String] resource String appended to the API endpoint
      #     URI, pool name, bucket name etc.
      # 
      # @return [Hash] Result of the HTTP GET
      #
      def get resource=nil

        time = Time.now
        if @data.empty? || time > @last_update + @ttl
          ur = "#{uri}#{resource || @resource}"
          begin
            @data = JSON.parse Net::HTTP.get URI ur
            @last_update = time
          rescue => e 
            print "Cannot retrieve data: #{e.message} (URI: #{ur}) "
          end
        end
        @data
      end

      
      # Class level method for the same. If it's only one time
      # request, just use it as ::Wizcorp::Subclass.get
      #
      # @param [Hash] params Same parameters as constructor acccepts.
      # @see initialize
      def self.get params={ }
        self.new(params).get
      end


      # Re-define standard method to handle all keys returned with
      # JSON object, so we can refer to the data by key-name
      def method_missing sym, key=nil
        get if data.empty?

        sym,key = sym.to_s,key.to_s

        if data.has_key?(sym)
             
          return data[sym] if key.empty?
          
          if data[sym].is_a?(Hash) && data[sym].has_key?(key)
            return data[sym][key]
          else
            return nil
          end
        else
          super sym.to_sym, key
        end          
      end

      
    end # class Connection
  end # module Couchbase
end
