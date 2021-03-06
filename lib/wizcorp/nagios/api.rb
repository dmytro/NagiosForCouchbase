module Wizcorp
  module Nagios
    class API
      
      require 'uri'
      require 'rest-client'

      def initialize params={ }

        @connection = { 
          :hostname => 'localhost',
          :port     => 4567,
          :base => ''
        }.merge(params)
        c = @connection
        @baseuri = "http://#{c[:hostname]}:#{c[:port]}/#{c[:base]}"
        @response = { }

      end

      attr_accessor :response


      # Submit data to Nagira API. Sets @response variable to
      # [RestClient.response]. can submit single check or multiple
      # checks for single host. If data is Array, then all the checks
      # are submitted with one HTTP request.
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
      #     overriden by host parameter. Data acceptable by
      #     +Nagira#put_status_host_name_services+ method
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
