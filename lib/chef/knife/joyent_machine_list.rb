require File.expand_path(File.dirname(__FILE__) + '/joyent_base')


class Chef
  class Knife
    class JoyentServerList < Knife

      include Knife::JoyentBase

      banner "knife joyent server list <options>"

      def run
        servers = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('State', :bold),
          ui.color('Type', :bold),
          ui.color('Dataset', :bold),
          ui.color('IPs', :bold),
          ui.color('Memory', :bold),
          ui.color('Disk', :bold),
        ]

        self.connection.servers.sort_by(&:id).each do |s|
          servers << s.id.to_s
          servers << s.name
          servers << s.state
          servers << s.type
          servers << s.dataset
          servers << s.ips.join(" ")
          servers << s.memory.to_s
          servers << s.disk.to_s
        end

        puts ui.list(servers, :columns_across, 8)
      end
    end
  end
end
