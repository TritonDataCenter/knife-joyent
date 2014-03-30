require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerPricing < Knife

      include Knife::JoyentBase

      option :reserve_pricing,
             :short => '-r <file>',
             :long => '--reserve-pricing <file>',
             :description => 'Apply reserve discounts from a YAML config (see joyent-cloud-pricing gem)',
             :proc => Proc.new { |key| Chef::Config[:knife][:reserve_pricing] = key }

      option :show_zones,
             :short => '-z',
             :long => '--show-zones',
             :description => 'Print list of on-demand zones sorted by price',
             :proc => Proc.new { |key| Chef::Config[:knife][:show_zones] = key }

      banner 'knife joyent server pricing [-r <reserve-pricing.yml> ] [ -z ] '

      def run
        flavors = []
        self.connection.servers.each do |s|
          flavor = s.respond_to?(:attributes) ? s.attributes['package'] : 'unknown'
          flavors << flavor
        end
        reporter = Joyent::Cloud::Pricing::Reporter.new(Chef::Config[:knife][:reserve_pricing], flavors)
        reporter.print_zone_list = Chef::Config[:knife][:show_zones]
        puts reporter.render
      rescue => e
        output_error(e)
      end
    end
  end
end
