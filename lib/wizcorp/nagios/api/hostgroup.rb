module Wizcorp
  module Nagios

    # Helper class to easy get list of hosts in hostgroup, only this
    # nothing more.
    class Hostgroup < API
      
      # Can accept either single group name or multiples.
      #
      # @option params [Array] :hostgroups array of groups to select hosts from
      #
      # @option params [String] :hostgroup Single hostgroup to quesry for host names
      def initialize params={ }
        super params.merge :base => '_objects/hostgroup'

        @hostgroups = ((params[:hostgroups] || []) << params[:hostgroup]).uniq.compact
        
        @hosts = []
      end


      # Build API endpoint URL using @base variable and host, service
      # pair.
      def endpoint  group
        path = [@baseuri, group] 
        URI.escape(path.join "/")
      end

      # Get list of hosts in hostgroup(s) from Nagira API.
      #
      # @param [String] groups List of comma separated hostgroups to
      #     query. If none provided that used instance veriables
      #     @hostgroups and @hostgroup
      #
      # @return [Array] List of hosts
      #
      def hosts groups=nil
        
        groups = case groups
                 when Array     then groups
                 when String    then Array[groups]
                 when NilClass  then @hostgroups
                 end

        @hosts = []

        groups.each do |gr|
          @response = RestClient.get endpoint gr
          @hosts << JSON.parse(@response)['members'].split(',')
        end

        @hosts.flatten.uniq
      end

    end
  end
end
