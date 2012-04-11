require File.expand_path(File.dirname(__FILE__) + '/base')

module KnifeJoyent
  class JoyentTagList < Chef::Knife

    include KnifeJoyent::Base

    banner "knife joyent tag list <server>"

    def run
      server = name_args.first

      unless server
        show_usage
        exit 1
      end

      tags = [
        ui.color('Name', :bold),
        ui.color('Value', :bold),
      ]

      self.connection.servers.get(server).tags.each do |k, v|
        tags << k
        tags << v
      end

      puts ui.list(tags, :uneven_columns_across, 2)
      exit 0
    rescue Excon::Errors::NotFound => e
      puts ui.error("Server #{server} not found")
      exit 1
    end
  end
end
