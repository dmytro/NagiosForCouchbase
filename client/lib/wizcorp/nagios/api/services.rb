module Wizcorp
  module Nagios
    class Services < API
      
      def initialize params={ }
        super params.merge :base => '_status'
      end

      # Build API endpoint URL using @base variable and host, service
      # pair.
      def endpoint  host, service=nil
        path = [@baseuri, host, "_services"] 
        path << service if service
        URI.escape(path.join "/")
      end


    end
  end
end
