require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerMetadataDelete < Knife

      include Knife::JoyentBase

      attr_reader :server

      banner 'knife joyent server metadata delete <server_id> <options>'

      option :keys,
        :short => "-k KEY",
        :long => "--key KEY",
        :description => "Key (or comma separated keys) to delete",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :all,
        :long => "--all",
        :description => "Delete all metadata",
        :boolean => true,
        :default => false

      def run
        unless name_args.size === 1
          show_usage
          exit 1
        end

        if config[:keys].empty? and not config[:all]
          show_usage
          exit 1
        end

        id = name_args.first

        @server = self.connection.servers.get(id)
        unless server
          puts ui.error("Server with id: #{id} not found")
          exit 1
        end

        delete_all_keys if config[:all]
        delete_keys

        if server.update_metadata(config[:metadata])
          puts ui.color("Updated metadata on #{id}", :cyan)
          exit 0
        else
          puts ui.error("Metadata update failed")
          exit 1
        end

      rescue => e
        output_error(e)
      end

      private

      def delete_all_keys
        if server.delete_all_metadata
          msg("Deleted all metadata on #{server.id}")
          exit 0
        else
          fail
        end
      end

      def delete_keys
        config[:keys].each do |key|
          if server.delete_metadata(key)
            msg("Deleted metadata key: #{key} on #{server.name}")
          else
            fail
          end
        end
        exit 0
      end

      def msg(msg)
        puts ui.color(msg, :cyan)
      end

      def fail
        puts ui.error("Metadata delete failed")
        exit 1
      end
    end
  end
end
