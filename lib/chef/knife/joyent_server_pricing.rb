require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerPricing < Knife

      include Knife::JoyentBase

      option :reserve_pricing,
             :short => '-r <file>',
             :long => '--reserve-pricing <file>',
             :description => 'Apply reserve pricing to instances that qualify from a YAML file (see joyent-cloud-pricing gem)',
             :proc => Proc.new { |key| Chef::Config[:knife][:reserve_pricing] = key }

      banner "knife joyent server pricing [-r <reserve-pricing-configuration.yml> ]"

      def run
        flavors = []
        self.connection.servers.each do |s|
          flavor = s.respond_to?(:attributes) ? s.attributes["package"] : 'unknown'
          flavors << flavor
        end
        reporter = Joyent::Cloud::Pricing::Reporter.new(Chef::Config[:knife][:reserve_pricing], flavors)
        puts reporter.render
      rescue => e
        output_error(e)
      end
    end
  end
end
