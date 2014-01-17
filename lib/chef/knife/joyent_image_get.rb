require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentImageGet < Knife

      include Knife::JoyentBase

      banner "knife joyent image get <image_id>"

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first
        # puts id
        res = self.connection.request(
          :method => "GET",
          :path => "/my/images/#{id}"
        )

        if res.status != 200
          output_error(res)
        else
          r = res.body
          ui.output(res.body)
        end
      end
    end
  end
end
