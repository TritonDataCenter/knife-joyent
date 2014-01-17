# encoding: UTF-8
#
require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentFwGet < Knife

      include Knife::JoyentBase

      banner "knife joyent fw get <fw_id>"

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first
        # puts id
        res = self.connection.request(
          :method => "GET",
          :path => "/my/fwrules/#{id}"
        )

        rules = [
          ui.color('ID', :bold),
          ui.color('Enabled', :bold),
          ui.color('Rule', :bold),
        ]

        if (res.status == 422)
          output_error(res)
        else
          r = res.body
          rules << r["id"]
          rules << (r["enabled"] ? ui.color("✓", :cyan) : "✗")
          rules << r["rule"]
          ui.list(rules, :uneven_columns_across, 3)
        end
      end
    end
  end
end
