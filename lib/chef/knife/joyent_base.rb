require 'chef/knife'

class Chef
  class Knife
    module JoyentBase

      def self.included(base)
        base.class_eval do
          deps do
            require 'fog'
            require 'net/ssh/multi'
            require 'readline'
            require 'chef/json_compat'
          end

          option :joyent_username,
            :short => '-U USERNAME',
            :long => '--joyent-username USERNAME',
            :description => 'Your Joyent username',
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_username]}

          option :joyent_password,
            :short => '-P PASSWORD',
            :long => '--joyent-password PASSOWRD',
            :description => 'Your Joyent password',
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_password]}

          option :joyent_url,
            :short => "-L JOYENT_API_URL",
            :long => "--joyent-api-url JOYENT_API_URL",
            :description => "Joyent API URL",
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_url]}
        end

        def connection
          @connection ||= begin
            connection = Fog::Compute.new(
              :provider => 'Joyent',
              :joyent_username => Chef::Config[:knife][:joyent_username],
              :joyent_password => Chef::Config[:knife][:joyent_password],
              :joyent_url => Chef::Config[:knife][:joyent_url]
            )
          end
        end
      end
    end
  end
end
