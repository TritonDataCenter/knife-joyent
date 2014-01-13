require 'chef/knife'
require_relative '../../knife-joyent/pricing'

class Chef
  class Knife
    module JoyentBase

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
            :long => '--joyent-password PASSWORD',
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

          option :joyent_keyphrase,
            :long => '--joyent-keyphrase <passpharse>',
            :description => 'ssh passphrase to use if no ssh-agent is present',
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_keyphrase] = key }

          option :joyent_api_url,
            :short => "-L JOYENT_API_URL",
            :long => "--joyent-api-url JOYENT_API_URL",
            :description => "Joyent API URL",
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_api_url] = key }

          option :joyent_version,
            :long => "--joyent-api-version JOYENT_API_VERSION",
            :description => "Joyent API version",
            :proc => Proc.new {|key| Chef::Config[:knife][:joyent_version] = key }
        end
      end

      def connection
        if (Chef::Config[:knife][:joyent_verify_peer] == false)
          Excon.defaults[:ssl_verify_peer] = false
        end

        @connection ||= begin
           Fog::Compute.new(
            :provider => 'Joyent',
            :joyent_username => locate_config_value(:joyent_username),
            :joyent_password => locate_config_value(:joyent_password),
            :joyent_keyname => locate_config_value(:joyent_keyname),
            :joyent_keyfile => locate_config_value(:joyent_keyfile),

            :joyent_url => locate_config_value(:joyent_api_url),
            :joyent_version => locate_config_value(:joyent_version)
          )
        end
      end

      def pricing
        @pricing ||= KnifeJoyent::Pricing::Config.new
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      def output_error_response(res)
        if (res.body['message'])
          ui.error ui.color(res.body["message"], :white)
        end

        if (res.body["errors"])
          errors = res.body["errors"]
          errors.each do |e|
            ui.error("[#{e["field"]}] #{e["message"]}")
          end
        end
      end

      def msg_pair(label, value = nil)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end
    end
  end
end
