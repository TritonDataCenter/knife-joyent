require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentKeyDelete < Knife

      include Knife::JoyentBase

      banner "knife joyent key delete <name>"

      def run
        unless name_args.size === 1
          show_usage
        end

        keyname = name_args.first

        begin
          self.connection.delete_key(keyname)
        rescue Excon::Errors::NotFound => e
          ui.error("Key [#{keyname}] does not exist.")
          exit 1
        rescue Excon::Errors::Conflict => e
          body = MultiJson.decode(e.response.body)
          ui.error(body["message"])
          exit 1
        end

        puts ui.color('Deleted key: '+keyname, :cyan)
        exit 0
      end
    end
  end
end
