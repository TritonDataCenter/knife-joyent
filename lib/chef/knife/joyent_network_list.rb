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
        ]

        self.connection.networks.each do |network|
          networks << network.id
          networks << network.name
        end

        puts ui.list(networks, :uneven_columns_across, 2)
        exit 0
      end
    end
  end
end
