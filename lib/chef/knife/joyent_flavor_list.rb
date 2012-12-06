require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentFlavorList < Knife

      include Knife::JoyentBase

      banner "knife joyent flavor list <options>"

      def run
        flavor_list = [
          ui.color('Name', :bold),
          ui.color('RAM', :bold),
          ui.color('Disk', :bold),
          ui.color('Swap', :bold),
        ]

        self.connection.flavors.sort_by(&:memory).each do |flavor|
          flavor_list << flavor.name.to_s
          flavor_list << "#{flavor.memory/1024} GB"
          flavor_list << "#{flavor.disk/1024} GB"
          flavor_list << "#{flavor.swap/1024} GB"
        end

        puts ui.list(flavor_list, :uneven_columns_across, 4)
      end
    end
  end
end
