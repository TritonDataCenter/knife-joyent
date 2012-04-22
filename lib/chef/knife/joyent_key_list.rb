require File.expand_path(File.dirname(__FILE__) + '/base')

module KnifeJoyent
  class JoyentKeyList < Chef::Knife

    include KnifeJoyent::Base

    banner "knife joyent key list"

    def run
      keys = [
        ui.color('Name', :bold),
        ui.color('Key', :bold),
      ]

      self.connection.keys.sort_by(&:name).each do |k|
        keys << k.name
        keys << k.key[0..32] + '...'
      end

      puts ui.list(keys, :uneven_columns_across, 2)

    end
  end
end
