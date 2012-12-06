require 'chef/knife'

module KnifeJoyent
  module Base

    def self.included(includer)
      includer.class_eval do
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
          :proc => Proc.new {|key| Chef::Config[:knife][:joyent_username] = key}

        option :joyent_password,
          :short => '-P PASSWORD',
          :long => '--joyent-password PASSOWRD',
          :description => 'Your Joyent password',
          :proc => Proc.new {|key| Chef::Config[:knife][:joyent_password] = key }

        option :joyent_keyname,
          :long => '--joyent-keyname name of ssh key for signature auth',
          :description => 'name of ssh key for signature auth',
          :proc => Proc.new {|key| Chef::Config[:knife][:joyent_keyname] = key }

        option :joyent_keyfile,
          :long => '--joyent-keyfile path to ssh private key for signature auth',
          :description => 'path to ssh private key for signature auth',
          :proc => Proc.new {|key| Chef::Config[:knife][:joyent_keyfile] = key }

        option :joyent_api_url,
          :short => "-L JOYENT_API_URL",
          :long => "--joyent-api-url JOYENT_API_URL",
          :description => "Joyent API URL",
          :proc => Proc.new {|key| Chef::Config[:knife][:joyent_api_url] = key }
      end

      def connection
        @connection ||= begin
          connection = Fog::Compute.new(
            :provider => 'Joyent',
            :joyent_username => Chef::Config[:knife][:joyent_username],
            :joyent_password => Chef::Config[:knife][:joyent_password],
            :joyent_keyname => Chef::Config[:knife][:joyent_keyname],
            :joyent_keyfile => Chef::Config[:knife][:joyent_keyfile],
            :joyent_url => Chef::Config[:knife][:joyent_api_url]
          )
        end
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end
    end
  end
end
