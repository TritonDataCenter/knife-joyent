require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentTagCreate < Knife

      include Knife::JoyentBase

      banner "knife joyent tag create <server_id> <tag> <value>"

      def run
        server = name_args[0]
        tagkey = name_args[1]
        tagvalue = name_args[2]

        unless server || tagkey || tagvalue
          show_usage
          exit 1
        end

        tags = [
          ui.color('Name', :bold),
          ui.color('Value', :bold),
        ]

        self.connection.servers.get(server).add_tags({tagkey => tagvalue}).each do |k, v|
          tags << k
          tags << v
        end

        puts ui.color("Updated tags for #{server}", :cyan)
        puts ui.list(tags, :uneven_columns_across, 2)
        exit 0
      rescue Excon::Errors::NotFound => e
        puts ui.error("Server #{server} not found")
        exit 1
      end
    end
  end
end
