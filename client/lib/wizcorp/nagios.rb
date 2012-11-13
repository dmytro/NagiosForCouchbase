module Wizcorp
  module Nagios
    class API
      
      require 'uri'
      require 'rest-client'

      def initialize params={ }
        # Defaults
        @connection = { 
          :hostname => 'localhost',
          :port     => 4567,
          :basepath => ''
        }.merge(params)
        c = @connection
        @base = "http://#{c[:hostname]}:#{c[:port]}#{c[:basepath]}/_status"
        @response = { }

      end

      attr_accessor :response

      # Build API endpoint URL using @base variable and host, service
      # pair.
      def endpoint  host, service=nil
        path = [@base, host, "_services"] 
        path << service if service
        URI.escape(path.join "/")
      end

      # Submit data to Nagira API. Sets @response variable to
      # [RestClient.response]. can submit single check or multiple
      # checks for single host. If data is Array, then all the checks
      # are submitted with one HTTP request.
      #
      # @param [Hash] data Nagios formatted data, acceptable by
      #     {Nagira#put_status_host_name_services} method
      #
      # @see Nagira#put_status_host_name_services
      #
      # @param [String] host Hostname of the server check is executed against (not API Nagira host).
      #
      # @param [String] content_type HTTP Content-type string
      #
      # @param [Hash, Array] data Input data for the status check
      #     submission. Should contain attributes: service_description
      #     :return_code, :plugin_output. Note, attribute host_name is
      #     overriden by host parameter. 
      #
      # 
      #
      # @return self
      def put host, data, content_type='application/json'

        data = [data] if data.is_a? Hash # Make sure it's an Array

        data.each { |item|  item.merge!(:host_name => host) }
        @response = RestClient.put endpoint(host), data.to_json
        self
      end

      alias :submit :put

    end
  end
end
