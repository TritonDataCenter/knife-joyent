require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentKeyAdd < Knife

      include Knife::JoyentBase

      banner "knife joyent key add -f <keyfile> -k <name>"

      option :keyname,
        :short => '-k KEY_NAME',
        :long => '--keyname KEY_NAME',
        :description => 'Name for identifying this key'

      option :keyfile,
        :short => '-f KEY_FILE',
        :long => '--keyfile KEY_FILE',
        :description => 'Full path to location of ssh public key'

      def run
        keyfile = config[:keyfile]
        keyname = config[:keyname]

        unless File.exists?(keyfile)
          ui.error('keyfile specified does not exist')
          exit 1
        end


        key = begin
                File.read(keyfile)
              rescue
                puts ui.error('Unable to read contents of keyfile')
                exit 1
              end


        begin
          r = self.connection.create_key(
            :name => keyname,
            :key => key
          )
        rescue Excon::Errors::Conflict => e
          body = MultiJson.decode(e.response.body)
          ui.error(body["message"])
          exit 1
        end

        puts ui.color('Created key: '+keyname, :cyan)
        exit 0
      end
    end
  end
end
