require 'chef/knife/joyent_base'

class Chef
  class Knife
  class JoyentSnapshotCreate < Knife

    include Knife::JoyentBase

    banner 'knife joyent snapshot create <server> <snapshot_name>'

    def run
      unless name_args.size == 2
        show_usage
        exit 1
      end

      server = name_args[0]
      ssname = name_args[1]

      snapshot = self.connection.snapshots.create(server, ssname)
      puts ui.color("Created snapshot", :cyan)
      puts ui.output({
        :server => snapshot.machine_id,
        :name => snapshot.name,
        :state => snapshot.state,
        :created => snapshot.created
      })
      exit 0
      rescue Excon::Errors::Conflict => e
        if e.response && e.response.body.kind_of?(String)
          error = MultiJson.decode(e.response.body)
          puts ui.error(error['message'])
          exit 1
        else
          puts ui.error(e.message)
          exit 1
        end
      rescue => e
        puts ui.error('Unexpected Error Occured:' + e.message)
        exit 1
      end
    end
  end
end
