require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerReboot < Knife

      include Knife::JoyentBase

      banner 'knife joyent server reboot <server_id>'

      def run
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

        if server.reboot
          puts ui.color("Rebooted Server #{id}", :cyan)
          exit 0
        else
          puts ui.error("Reboot server failed")
          exit 1
        end
      end
    end
  end
end
