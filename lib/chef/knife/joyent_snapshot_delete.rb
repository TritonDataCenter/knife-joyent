require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentSnapshotDelete < Knife

      include Knife::JoyentBase

      banner 'knife joyent snapshot delete <server> <snapshot_name>'

      def run
        unless name_args.size == 2
          show_usage
          exit 1
        end

        server = name_args[0]
        ssname = name_args[1]

        snapshot = self.connection.snapshots.get(server, ssname)
        snapshot.destroy
        puts ui.color("Deleted snapshot #{snapshot.name}", :cyan)
        exit 0
      rescue Excon::Errors::NotFound => e
        puts ui.error("Snapshot #{ssname} on server #{server} not found")
        exit 1
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
