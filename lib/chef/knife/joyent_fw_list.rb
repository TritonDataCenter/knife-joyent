# encoding: UTF-8
require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentFwList < Knife

      include Knife::JoyentBase

      banner "knife joyent fw list"

      def run
        if name_args.size > 0
          id = name_args.first
          res = self.connection.request(
            :method => "GET",
            :path => "/my/machines/#{id}/fwrules"
          )
        else
          res = self.connection.request(
            :method => "GET",
            :path => "/my/fwrules"
          )
        end

        if res.status == 200
          rules = [
            ui.color('ID', :bold),
            ui.color('Enabled', :bold),
            ui.color('Rule', :bold),
          ]

          res[:body].each do |r|
            rules << r["id"]
            rules << (r["enabled"] ? ui.color("✓", :cyan) : "✗")
            rules << r["rule"]
          end
          ui.output ui.list(rules, :uneven_columns_across, 3)
        else
          output_error(res)
        end
      end
    end
  end
end
