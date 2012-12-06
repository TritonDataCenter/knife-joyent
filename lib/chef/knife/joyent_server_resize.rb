require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerResize < Knife

      include Knife::JoyentBase

      banner 'knife joyent server resize <server_id> -f <flavor>'

      option :flavor,
        :short => "-f <flavor>",
        :long => "--flavor <flavor>",
        :description => "name of flavor/package to resize to"

      def run
        unless config[:flavor]
          show_usage
          exit 1
        end

        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first

        server = self.connection.servers.get(id)
        unless server
          puts ui.error("Server with id: #{id} not found")
          exit 1
        end

        if self.connection.resize_machine(id, config[:flavor])
          puts ui.color("Resized server #{id}", :cyan)
          exit 0
        else
          puts ui.error("Resize server failed")
          exit 1
        end
      end
    end
  end
end
