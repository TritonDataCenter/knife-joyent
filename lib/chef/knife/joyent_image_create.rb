require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentImageCreate < Knife

      include Knife::JoyentBase

      banner "knife joyent image create <options>"

      option :server,
        :long => "--server <server_uuid>",
        :description => "server uuid to create machine from",
        :required => true

      option :name,
        :long => "--name <image_name>",
        :description => "name of custom image",
        :required => true

      option :version,
        :long => "--version <image_version>",
        :description => "version of custom image",
        :required => true

      option :description,
        :long => "--description <image description>",
        :description => "description of custom image (optional)"

      option :homepage,
        :long => "--homepage <homepage>",
        :description => "homepage of custom image (optional)"

      option :eula,
        :long => "--eula <eula>",
        :description => "EULA of custom image"

      option :acl,
        :long => "--acl <eula>",
        :description => "ACL (json) of custom image see: https://images.joyent.com/docs/#manifest-acl"

      option :tags,
        :long => "--tags <tags>",
        :description => "tags (json) of custom image"

      def image_create_options
        opts = {}
        opts["machine"] = config[:server] if config[:server]
        opts["name"] = config[:name] if config[:name]
        opts["version"] = config[:version] if config[:version]
        opts["description"] = config[:description] if config[:description]
        opts["eula"] = config[:eula] if config[:eula]
        opts["acl"] = config[:acl] if config[:acl]
        opts["tags"] = config[:tags] if config[:tags]
        opts
      end

      def run
        # puts image_create_options.inspect
        res = self.connection.request(
          :method => "POST",
          :path => "/my/images",
          :body => image_create_options
        )
        if (res.status == 201)
          ui.info ui.color("Creating Image from server #{config[:server]}...", :cyan)
          ui.output(res.body)
        else
          output_error(res)
        end
      end
    end
  end
end
