require File.expand_path(File.dirname(__FILE__) + '/base')


module KnifeJoyent
  class JoyentServerDelete < Chef::Knife

    include KnifeJoyent::Base

    banner 'knife joyent server delete <server_id>'

    def run
      unless name_args.size === 1
        show_usage
        exit 1
      end

      id = name_args.first

      server = self.connection.servers.get(id)
      
      msg("ID", server.id.to_s)
      msg("Name", server.name)
      msg("State", server.state)
      msg("Type", server.type)
      msg("Dataset", server.dataset)
      msg("IP's", server.ips)

      puts "\n"
      confirm("Do you really want to delete this server")

      unless server
        puts ui.error("Unable to locate server: #{id}")
        exit 1
      end

      if server.stopped?
        puts ui.color("Server #{id} is already stopped", :cyan)
        server.destroy
        puts ui.color("Deleted server: #{id}", :cyan)
        exit 0
      end
      
      if server.stop
        ui.color("Stopping server: #{id}", :cyan)
        # until server.stopped?
        #           puts ui.color(".", :cyan)
        #         end
        server.destroy
        puts ui.color("Deleted server: #{id}", :cyan)
        exit 0
      else
        puts ui.error("Failed to delete server")
        exit 1
      end
    end
    
    def msg(label, value)
      if value && !value.empty?
        puts "#{ui.color(label, :cyan)}: #{value}"
      end
    end
  end
end
