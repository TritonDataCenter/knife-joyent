require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentSnapshotList < Knife

      include Knife::JoyentBase

      banner "knife joyent snapshot list <server_id>"

      def run

        unless name_args.size == 1
          show_usage
          exit 1
        end

        server = name_args.first

        snapshots = [
          ui.color('ID', :bold),
          ui.color('State', :bold),
          ui.color('Created', :bold),
        ]

        self.connection.snapshots.all(server).each do |s|
          snapshots << ui.color(s.name, :bold)
          snapshots << case s.state
          when "queued" then
            ui.color(s.state, :yellow)
          when "success" then
            ui.color(s.state, :green)
          else
            ui.color(s.state, :red)
          end
          snapshots << s.created.to_s
        end

        puts ui.list(snapshots, :uneven_columns_across, 3)
      rescue Fog::Compute::Joyent::Errors::NotFound
        puts ui.error("Server #{server} not found.")
      end
    end
  end
end
