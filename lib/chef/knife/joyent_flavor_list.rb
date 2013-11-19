require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentFlavorList < Knife

      include Knife::JoyentBase

      banner "knife joyent flavor list <options>"

      def run

        flavor_list = [
          ui.color('Name', :bold),
          ui.color('      RAM', :bold),
          ui.color('     Disk', :bold),
          ui.color('    Swap', :bold),
          ui.color('Price $/Hr', :bold),
        ]

        self.connection.flavors.sort_by(&:memory).each do |flavor|
          flavor_list << flavor.name.to_s
          flavor_list << "#{sprintf "%6.2f", flavor.memory/1024.0} GB"
          flavor_list << "#{sprintf "%6.0f", flavor.disk/1024.0} GB"
          flavor_list << "#{sprintf "%5.0f", flavor.swap/1024.0} GB"
          flavor_list << (pricing[flavor.name.to_s] ? sprintf("$%.3f", pricing[flavor.name.to_s]) : "")
        end

        puts ui.list(flavor_list, :uneven_columns_across, 5)
      end
    end
  end
end
