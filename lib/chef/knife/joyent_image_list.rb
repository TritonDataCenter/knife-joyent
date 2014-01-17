require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentImageList < Knife

      include Knife::JoyentBase

      banner "knife joyent image list <options>"

      option :public,
        :boolean => true,
        :long => "--public <true/false>",
        :description => "filter public/private images"

      option :state,
        :long => "--state <all/active/unactivated/disabled>",
        :default => "active",
        :description => "filter images by state (default: active)"

      option :owner,
        :long => "--owner <owner_uuid>",
        :description => "filter images by owner (default: none)"

      option :type,
        :long => "--type <smartmachine/virtualmachine>",
        :description => "filter images by image type (default: all)"

      def run
        images = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Version', :bold),
          ui.color('OS', :bold),
          ui.color('Type', :bold),
          ui.color('State', :bold),
        ]

        query = {}
        query[:public] = config[:public] if config[:public]
        query[:state] = config[:state] if config[:state]
        query[:owner] = config[:owner] if config[:owner]
        query[:type] = config[:type] if config[:type]

        res = self.connection.request(
          :method => "GET",
          :query => query,
          :path => "/my/images",
        )

        if res.status == 200
          data = res.body
        else
          output_error(res)
          exit 1
        end

        data.sort_by do |v|
          v["name"]
        end.each do |i|
          images << i["id"]
          images << i["name"]
          images << i["version"]
          images << i["os"]
          images << i["type"]
          images << i["state"]
        end

        ui.output ui.list(images, :uneven_columns_across, 6)
      rescue => e
        output_error(e)

      end
    end
  end
end
