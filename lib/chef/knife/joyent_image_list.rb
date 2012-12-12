require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentImageList < Knife

      include Knife::JoyentBase

      banner "knife joyent image list <options>"

      def run
        images = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Version', :bold),
          ui.color('OS', :bold),
          ui.color('Type', :bold),
        ]

        self.connection.images.sort_by(&:name).each do |i|
          images << i.id.to_s
          images << i.name
          images << i.version
          images << i.os
          images << i.type
        end

        puts ui.list(images, :uneven_columns_across, 5)
      end
    end
  end
end
