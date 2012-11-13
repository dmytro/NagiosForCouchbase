module Wizcorp
  module Couchbase

    # Class to establish connection and handle communication with
    # Couchbase server HTTP API.
    class Connection

      require 'net/http' 
      require 'json'
      require 'pp'

      def initialize connection={}
        # Set default values
        @connection = { 
          :hostname => 'localhost',
          :port => 8091,
          :pool => 'default',
          :buckets => ['default'],
        }.merge(connection)

        @resource = nil

        c = @connection

        @uri = "http://#{c[:hostname]}:#{c[:port]}/pools/"
        @data = { }

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
        ur = "#{uri}#{resource || @resource}"
pp ur
        begin
          @data = JSON.parse Net::HTTP.get URI ur
        rescue => e 
          print "Cannot retrieve data: #{e.message} (URI: #{ur}) "
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
        sym = sym.to_s
        key = key.to_s

        super unless data.has_key?(sym)

        return data[sym] if key.empty?
    
        if data[sym].is_a?(Hash) && data[sym].has_key?(key)
          return data[sym][key]
        else
          return nil
        end
          
      end
      
    end # class Connection
  end # module Couchbase
end
