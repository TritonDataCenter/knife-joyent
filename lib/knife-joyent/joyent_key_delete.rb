require File.expand_path(File.dirname(__FILE__) + '/base')


module KnifeJoyent
  class JoyentKeyDelete < Chef::Knife

    include KnifeJoyent::Base

    banner "knife joyent key delete -k <name>"

    option :keyname,
      :short => '-k KEY_NAME',
      :long => '--keyname KEY_NAME',
      :description => 'Name of the key to delete'

    def run
      keyname = config[:keyname]

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
