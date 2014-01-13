require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentFwDelete < Knife

      include Knife::JoyentBase

      banner "knife joyent fw delete <fw_id>"

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first
        # puts id
        res = self.connection.request(
          :method => "DELETE",
          :path => "/my/fwrules/#{id}"
        )

        rules = [
          ui.color('ID', :bold),
          ui.color('Enabled', :bold),
          ui.color('Rule', :bold),
        ]

        if res.status == 204
          ui.info "Rule #{id} Deleted."
        else
          self.output_error_response(res)
        end

      end
    end
  end
end
