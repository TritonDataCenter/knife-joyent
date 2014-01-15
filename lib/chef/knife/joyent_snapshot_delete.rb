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
      rescue => e
        output_error(e)
        exit 1
      end
    end
  end
end
