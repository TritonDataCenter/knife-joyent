require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerFwEnable < Knife

      include Knife::JoyentBase

      banner "knife joyent server fw enable <server_id>"

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first
        # puts id
        res = self.connection.request(
          :method => "POST",
          :path => "/my/machines/#{id}",
          :query => {"action" => "enable_firewall"}
        )

        if (res.status === 202)
          ui.info ui.color("Firewall Enabled for server #{id}", :cyan)
        else
          output_error_response(res)
        end
      end
    end
  end
end
