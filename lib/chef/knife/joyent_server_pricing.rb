require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerPricing < Knife

      include Knife::JoyentBase

      option :reserve_pricing,
             :short => '-r <file>',
             :long => '--reserve-pricing <file>',
             :description => 'Apply custom pricing from a YAML file (see: joyent-cloud-pricing gem)',
             :proc => Proc.new { |key| Chef::Config[:knife][:reserve_pricing] = key }

      option :show_zones,
             :short => '-z',
             :long => '--show-zone-flavors',
             :description => 'Print aggregated list of zone flavors sorted by price',
             :proc => Proc.new { |key| Chef::Config[:knife][:show_zones] = key }

      option :no_color,
             :long => '--no-color',
             :description => 'Disable color when printing',
             :proc => Proc.new { |key| Chef::Config[:knife][:no_color] = true }

      banner 'knife joyent server pricing [-r <custom-pricing.yml>] [-z] [--no-color]'

      def run
        flavors = []
        self.connection.servers.each do |s|
          flavor = s.package || 'unknown'
          flavors << flavor
        end
        config = Chef::Config[:knife]
        reporter = Joyent::Cloud::Pricing::Reporter.new(config[:reserve_pricing], flavors)
        reporter.print_zone_list = config[:show_zones]
        puts reporter.render(:disable_color => config[:no_color])
      rescue => e
        output_error(e)
      end
    end
  end
end
