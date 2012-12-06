require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerStart < Knife

      include Knife::JoyentBase

      banner 'knife joyent server start <server_id>'

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

        if server.ready?
          puts ui.error("Server is already started")
          exit 1
        end

        if server.start
          puts ui.color("Started server: #{id}", :cyan)
          exit 0
        else
          puts ui.error("Start server failed")
          exit 1
        end
      end
    end 
  end
end
