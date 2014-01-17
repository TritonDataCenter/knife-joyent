require 'chef/knife/joyent_base'
require 'pp'

class Chef
  class Knife
    class JoyentFwUpdate < Knife

      include Knife::JoyentBase

      banner "knife joyent fw update <rule_id> (options)"

      option :rule,
        :long => "--rule RULE",
        :description => "Firewall Rule Content",
        :required => true

      option :enabled,
        :long => "--enabled",
        :boolean => true,
        :description => "Enable/Disable Rule"


      def run
        id = name_args.first
        unless id || (!config.key?(:rule) || !config.key?(:enabled))
          show_usage
          exit 1
        end

        res = self.connection.request(
          :method => "POST",
          :path => "/my/fwrules/#{id}",
          :body => {
            "enabled" => config[:enabled],
            "rule" => config[:rule],
          }
        )

        unless res.status == 200
          output_error(res)
        else
          r = res.body

          ui.info ui.color("Updated Firewall Rule: #{r["id"]}", :bold)
          msg_pair "RULE", r["rule"]
          msg_pair "ENABLED", (r["enabled"] ? ui.color("✓ YES", :cyan) : "✗ NO")
        end
      end
    end
  end
end
