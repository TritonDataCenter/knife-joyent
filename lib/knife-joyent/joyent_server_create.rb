module KnifeJoyent
  class JoyentServerCreate < Chef::Knife

    include KnifeJoyent::Base

    banner 'knife joyent server create (options)'

    option :name,
      :long => '--name <name>',
      :description => 'name for this machine'

    option :package,
      :long => '--flavor <name>',
      :description => 'specify flavor/package for the server'

    option :dataset,
      :short => '--image <id>',
      :description => 'specify image for the server'

    def run
      if s = self.connection.servers.create(:dataset => config[:dataset],
                                            :package => config[:package],
                                            :name => config[:name])
        puts ui.color("Created machine: #{s.uuid}", :cyan)
        exit 0
      end
    rescue => e
      if e.response && e.response.body.kind_of?(String)
        error = MultiJson.decode(e.response.body)
        puts ui.error(error['message'])
        exit 1
      else
        puts ui.error('Unexpected Error Occured:' + e.message)
      end
    end

  end
end
