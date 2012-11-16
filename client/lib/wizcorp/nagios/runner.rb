module Wizcorp
  module Nagios
    class Runner

      # Run all checks for all configured hosts with single command.
      def self.run_all params={ }
        hosts = APP[:buckets].keys
        
        hosts.each do |host|
          self.new(host, params).submit
        end
      end


      # Build list of hosts/bucket pairs to run checks. All other
      # procedures should not access configuration directly, but rely
      # on the output provided by this method. When configuration
      # changes only ned to change this method.
#       def self.buckets
#         if APP.has_key? :hosts
#           APP[:buckets][:hosts]
#         else
#         end
#       end

      # @param [String] hostname Couchbase server hostname.
      #
      # Initialize all checks array for single Couchbase server,
      # initialize Nagios/Nagira API endpoint, too. Connection to
      # Couchbase server initialized for each bucket configured on
      # that server.
      #
      # For connection information configuration in APP and CHECKS
      # hashes is used.
      #
      # TODO: Later use information from Nagios server for the list of
      # servers (query 'Membase' hostgroup).

      def initialize hostname, params={ }
        checks = CHECKS.keys.reject { |x| x == 'default'}

        @hostname = hostname
        @buckets = APP[:buckets][hostname]
        
        @checks, @status = [], []
        
        checks.each do |check|
          @buckets.each do |bucket|
            @checks << Checks.new(check, {:hostname => hostname, :bucket => bucket})
          end
        end
        
        @api = Services.new APP[:nagios][:api].merge(params)
      end

      attr_accessor :hostname, :checks, :api, :status
      
      # Collect information for all checks on this host. Populate
      # !@status Array.
      def run
        checks.each {  |c| @status << c.rag }
        self
      end

      # Send collected information to Nagios API. If @status is empty
      # (was not run), run it from here.
      def submit
        run if @status.empty?
        api.put hostname, status
        self
      end

    end
  end
end
