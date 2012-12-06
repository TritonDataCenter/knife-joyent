require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentTagDelete < Knife

      include Knife::JoyentBase

      banner ["knife joyent tag delete <server_id> <tag>",
              "knife joyent tag delete <server_id> -A"].join("\n")


      option :all,
        :short => "-A",
        :long => "--all",
        :boolean => true,
        :description => "delete all tags on the machine"

      def run
        server_id = name_args[0]
        tagname = name_args[1]
        all = config[:all]

        if !server_id || (all == false && !tagname) || (all && tagname)
          show_usage
          exit 1
        end

        begin
          server = self.connection.servers.get(server_id)
        rescue Excon::Errors::NotFound => e
          puts ui.error("Server #{server_id} not found")
          exit 1
        end

        if all
          server.delete_all_tags
          puts ui.color("Deleted all tags for #{server_id}", :cyan)
          exit 0
        else
          begin
            server.delete_tag(tagname)
          rescue Excon::Errors::NotFound => e
            puts ui.error("Tag #{tagname} on server #{server_id} not found")
            exit 1
          end

          tags = [
            ui.color('Name', :bold),
            ui.color('Value', :bold),
          ]

          server.reload.tags.each do |k, v|
            tags << k
            tags << v
          end
          puts ui.color("Deleted tag #{tagname} for #{server_id}", :cyan)
          puts ui.list(tags, :uneven_columns_across, 2)
        end
        exit 0
      end
    end
  end
end
