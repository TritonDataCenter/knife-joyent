require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerMetadataUpdate < Knife

      include Knife::JoyentBase

      banner 'knife joyent server metadata update <server_id> -m <json>'

      option :metadata,
        :short => "-m JSON",
        :long => "--metadata JSON",
        :description => "Metadata to be applied to server",
        :proc => Proc.new { |m| JSON.parse(m) },
        :default => {}

      def run
        if config[:metadata].empty?
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

        if server.update_metadata(config[:metadata])
          puts ui.color("Updated metadata on #{id}", :cyan)
          exit 0
        else
          puts ui.error("Metadata update failed")
          exit 1
        end
      end
    end
  end
end
