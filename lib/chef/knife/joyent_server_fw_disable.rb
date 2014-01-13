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

        res = self.connection.request(
          :method => "POST",
          :path => "/my/machines/#{id}",
          :body => { :action => "disable_firewall"}
        )

        if (res.status === 202)
          ui.color(:cyan, "FIrewall Disabled for server #{id}")
        else
          output_error_response(res)
        end
      end
    end
  end
end
