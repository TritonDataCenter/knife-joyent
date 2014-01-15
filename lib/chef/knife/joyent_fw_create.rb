require 'chef/knife/joyent_base'
require 'pp'

class Chef
  class Knife
    class JoyentFwCreate < Knife

      include Knife::JoyentBase

      banner "knife joyent fw create (options)"

      option :rule,
        :long => "--rule RULE",
        :description => "Firewall Rule Content"

      option :enabled,
        :long => "--enabled",
        :boolean => true,
        :description => "Enable/Disable Rule"

      def run
        unless config[:rule]
          show_usage
          exit 1
        end

        res = self.connection.request(
          :method => "POST",
          :path => "/my/fwrules",
          :body => {
            "enabled" => config[:enabled],
            "rule" => config[:rule],
          }
        )

        unless res.status == 201
          output_error(res)
        else
          r = res.body

          ui.info "Created Firewall Rule: #{r["id"]}"
          msg_pair "RULE", r["rule"]
          msg_pair "ENABLED", (r["enabled"] ? ui.color("✓ YES", :cyan) : "✗ NO")
        end
      rescue => e
        output_error(e)
      end
    end
  end
end
