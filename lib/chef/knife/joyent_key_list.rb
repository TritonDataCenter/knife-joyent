require File.expand_path(File.dirname(__FILE__) + '/joyent_base')


class Chef
  class Knife
    class JoyentKeyList < Knife

      include Knife::JoyentBase

      banner "knife joyent machine list <options>"

      def run
        keys = [
          ui.color('Name', :bold),
          ui.color('Key', :bold),
        ]

        self.connection.keys.sort_by(&:name).each do |k|
          keys << k.name
          keys << k.key[0..32] + '...'
        end

        puts ui.list(keys, :columns_across, 2)

      end
    end
  end
end
