require 'chef/knife/joyent_base'

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
          ui.color('Image', :bold),
          ui.color('Flavor', :bold),
          ui.color('IPs', :bold),
          ui.color('      RAM', :bold),
          ui.color('    Disk', :bold),
          ui.color('Tags', :bold)
        ]

        self.connection.servers.sort do |a, b|
          (a.name || '') <=> (b.name || '')
        end.each do |s|
          servers << s.id.to_s
          servers << s.name

          servers << case s.state
          when 'running'
            ui.color(s.state, :green)
          when 'stopping', 'provisioning'
            ui.color(s.state, :yellow)
          when 'stopped'
            ui.color(s.state, :red)
          else
            ui.color('unknown', :red)
          end

          servers << s.type
          servers << s.dataset
          servers << s.attributes["package"] || 'Unknown'
          servers << s.ips.join(",")
          servers << "#{sprintf "%6.2f", s.memory/1024.0} GB".to_s
          servers << "#{sprintf "%5.0f",   s.disk/1024} GB".to_s

          if (s.tags rescue nil)
            servers << s.tags.map { |k, v| "#{k}:#{v}" }.join(' ')
          else
            servers << "No Tags"
          end
        end

        puts ui.list(servers, :uneven_columns_across, 10)
      end
    end
  end
end
