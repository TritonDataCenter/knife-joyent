require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerFwDisable < Knife

      include Knife::JoyentBase

      banner "knife joyent server fw disable <server_id>"

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first

        path = "/my/machines/#{id}"
        res = self.connection.request(
          :method => "POST",
          :path => path,
          :query => {"action" => "disable_firewall"}
        )

        if (res.status == 202)
          puts ui.color("Firewall Disabled for server #{id}", :cyan)
        else
          output_error(res)
        end
      end
    end
  end
end
