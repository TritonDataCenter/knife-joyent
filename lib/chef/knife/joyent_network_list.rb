require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentNetworkList < Knife
      include Knife::JoyentBase

      banner "knife joyent network list"

      def run
        networks = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color(''),
        ]

        self.connection.networks.each do |network|
          networks << network.id
          networks << network.name
          networks << (network.public ? 'public' : 'private')
        end

        puts ui.list(networks, :uneven_columns_across, 3)
        exit 0
      end
    end
  end
end
