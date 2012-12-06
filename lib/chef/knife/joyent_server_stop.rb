require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerStop < Knife

      include Knife::JoyentBase

      banner 'knife joyent server stop <server_id>'

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        id = name_args.first

        server = self.connection.servers.get(id)

        unless server
          puts ui.error("Unable to locate server: #{id}")
          exit 1
        end

        if server.stopped?
          puts ui.error("Server #{id} is already stopped")
          exit 1
        end

        if server.stop
          puts ui.color("Stopped server: #{id}", :cyan)
          exit 0
        else
          puts ui.error("Failed to stop server")
          exit 1
        end
      end
    end
  end
end
