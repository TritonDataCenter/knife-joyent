require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerCreate < Knife

      include Knife::JoyentBase

      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        require 'ipaddr'
        Chef::Knife::Bootstrap.load_deps
      end

      banner 'knife joyent server create (options)'

      option :server_name,
        :short => "-S NAME",
        :long => "--server-name NAME",
        :description => "The Joyent server name (may contain letters, numbers, dashes, and periods)"

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node"

      option :package,
        :short => '-f FLAVOR_NAME',
        :long => '--flavor FLAVOR_NAME',
        :description => 'specify flavor/package for the server'

      option :dataset,
        :short => '-I IMAGE_ID',
        :long => '--image IMAGE_ID',
        :description => 'specify image for the server'

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :json_attributes,
        :short => "-j JSON",
        :long => "--json-attributes JSON",
        :description => "A JSON string to be added to the first run of chef-client",
        :proc => lambda { |o| JSON.parse(o) },
        :default => {}

      option :networks,
        :short => "-w NETWORKS",
        :long => "--networks NETWORKS",
        :description => "Comma separated list of networks to attach (currently requires API version >= 7.0 in knife.rb)",
        :proc => lambda { |n| n.split(/[\s,]+/)},
        :default => nil

      option :private_network,
        :long => "--private-network",
        :description => "Use the private IP for bootstrapping rather than the public IP",
        :boolean => true,
        :default => false

      option :tags,
        :long => "--tags JSON",
        :description => "JSON-encoded {key:value} pairs tag server with",
        :proc => Proc.new { |m| JSON.parse(m) },
        :default => nil

      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME",
        :description => "The ssh username",
        :default => "root"

      option :identity_file,
        :short => "-i IDENTITY_FILE",
        :long => "--identity-file IDENTITY_FILE",
        :description => "The SSH identity file used for authentication"

      option :prerelease,
        :long => "--prerelease",
        :description => "Install the pre-release chef gems"

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "chef-full"

      option :joyent_metadata,
        :long => '--metadata JSON',
        :description => 'Metadata to apply to machine',
        :proc => Proc.new { |m| JSON.parse(m) },
        :default => {}

      option :no_host_key_verify,
        :long => "--no-host-key-verify",
        :description => "Disable host key verification",
        :boolean => true,
        :default => false

      option :ssh_gateway,
        :short => "-gw GATEWAY",
        :long => "--ssh-gateway GATEWAY",
        :description => "The ssh gateway server",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

      option :ssh_init_delay,
        :long => "--ssh-init-delay SECS",
        :description => "Seconds to sleep after SSH starts answering on new machine",
        :default => 10

      def is_linklocal(ip)
        linklocal = IPAddr.new "169.254.0.0/16"
        return linklocal.include?(ip)
      end

      def is_loopback(ip)
        loopback = IPAddr.new "127.0.0.0/8"
        return loopback.include?(ip)
      end

      def is_private(ip)
        block_a = IPAddr.new "10.0.0.0/8"
        block_b = IPAddr.new "172.16.0.0/12"
        block_c = IPAddr.new "192.168.0.0/16"
        return (block_a.include?(ip) or block_b.include?(ip) or block_c.include?(ip))
      end

      def tcp_test_ssh(hostname)
        ssh_test_max = 10*60
        ssh_test = 0
        until _tcp_test_ssh(hostname)
          if ssh_test < ssh_test_max
            print(".")
            ssh_test += 1
            sleep 1
          else
            puts ui.error("Unable to ssh to node (#{bootstrap_ip_address}), exiting")
            exit 1
          end
        end
      end


      def run
        $stdout.sync = true

        validate_server_name

        @node_name = config[:chef_node_name] || config[:server_name]

        puts ui.color("Creating machine #{@node_name}", :cyan)

        server = connection.servers.create(server_creation_options)

        puts ui.color("Waiting for Server to be Provisioned", :magenta)
        server.wait_for { print "."; ready? }

        bootstrap_ip = self.determine_bootstrap_ip(server)

        unless bootstrap_ip
          puts ui.error("No IP address available for bootstrapping.")
          exit 1
        end

        Chef::Log.debug("Bootstrap IP Address #{bootstrap_ip}")
        puts "\n"
        puts ui.color("Bootstrap IP Address #{bootstrap_ip}", :cyan)

        if config[:tags]
          tags = [ ui.color('Name', :bold), ui.color('Value', :bold) ]

          server.add_tags(config[:tags]).each do |k,v|
            tags << k
            tags << v
          end

          puts ui.color("Updated tags for #{@node_name}", :cyan)
          puts ui.list(tags, :uneven_columns_across, 2)
        end

        if Chef::Config[:knife][:provisioner]
          tags = [ ui.color('Name', :bold), ui.color('Value', :bold) ]
          # tag the provision with 'provisioner'
          server.add_tags({'provisioner' => Chef::Config[:knife][:provisioner]}).each do |k, v|
            tags << k
            tags << v
          end
          puts ui.color("Updated tags for #{@node_name}", :cyan)
          puts ui.list(tags, :uneven_columns_across, 2)
        else
          puts ui.color("No user defined in knife config for provision tagging -- continuing", :magenta)
        end

        puts ui.color("Created machine:", :cyan)
        msg_pair("ID", server.id.to_s)
        msg_pair("Name", server.name)
        msg_pair("State", server.state)
        msg_pair("Type", server.type)
        msg_pair("Dataset", server.dataset)
        msg_pair("IPs", server.ips.join(" "))
        msg_pair("Tags", config[:tags]) if config[:tags]
        msg_pair("JSON Attributes",config[:json_attributes]) unless config[:json_attributes].empty?

        puts ui.color("Waiting for server to fully initialize...", :cyan)
        sleep 20

        puts ui.color("Waiting for SSH to come up on: #{bootstrap_ip}", :cyan)
        tcp_test_ssh(bootstrap_ip)

        puts ui.color("Sleeping for #{config[:ssh_init_delay]} seconds", :cyan)
        sleep config[:ssh_init_delay]

        bootstrap_for_node(server, bootstrap_ip).run

      rescue => e
        output_error(e)
        exit 1
      end

      # Run Chef bootstrap script
      def bootstrap_for_node(server, bootstrap_ip)
        bootstrap = Chef::Knife::Bootstrap.new
        Chef::Log.debug("Bootstrap name_args = [ #{bootstrap_ip} ]")
        bootstrap.name_args = [ bootstrap_ip ]

        Chef::Log.debug("Bootstrap run_list = #{config[:run_list]}")
        bootstrap.config[:run_list] = config[:run_list]

        Chef::Log.debug("Bootstrap ssh_user = #{config[:ssh_user]}")
        bootstrap.config[:ssh_user] = config[:ssh_user]

        Chef::Log.debug("Bootstrap chef_node_name = #{config[:chef_node_name]}")
        bootstrap.config[:chef_node_name] = config[:chef_node_name] || server.id

        Chef::Log.debug("Bootstrap prerelease = #{config[:prerelease]}")
        bootstrap.config[:prerelease] = config[:prerelease]

        Chef::Log.debug("Bootstrap distro = #{config[:distro]}")
        bootstrap.config[:distro] = config[:distro]

        if config[:ssh_user] == 'root'
          bootstrap.config[:use_sudo] = false
        else
          bootstrap.config[:use_sudo] = true
        end

        Chef::Log.debug("Bootstrap use_sudo = #{bootstrap.config[:use_sudo]}")

        bootstrap.config[:environment] = config[:environment]
        Chef::Log.debug("Bootstrap environment = #{bootstrap.config[:environment]}")

        bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]
        Chef::Log.debug("Bootstrap no_host_key_verify = #{bootstrap.config[:no_host_key_verify]}")

        bootstrap.config[:identity_file] = config[:identity_file]
        Chef::Log.debug("Bootstrap identity_file = #{bootstrap.config[:identity_file]}")

        bootstrap.config[:ssh_gateway] = determine_ssh_gateway(bootstrap_ip)
        Chef::Log.debug("Bootstrap ssh_gateway= #{bootstrap.config[:ssh_gateway]}")

        bootstrap.config[:first_boot_attributes] = config[:json_attributes]
        Chef::Log.debug("Bootstrap json_attributes = #{bootstrap.config[:json_attributes]}")

        bootstrap
      end

      # src: https://github.com/chef/knife-ec2/blob/master/lib/chef/knife/ec2_server_create.rb#L741-L770
      def determine_ssh_gateway
        # ssh_gateway config takes precedence over derived value
        if config[:ssh_gateway]
          Chef::Log.debug("Using ssh gateway #{config[:ssh_gateway]} from knife config")
          return config[:ssh_gateway]
        end

        ssh_proxy = Net::SSH::Config.for(hostname)[:proxy]
        if ssh_proxy.respond_to?(:command_line_template)
          # ssh gateway_hostname nc %h %p
          proxy_pattern = /ssh\s+(\S+)\s+nc/
          matchdata = proxy_pattern.match(ssh_proxy.command_line_template)
          if matchdata.nil?
            Chef::Log.debug("Unable to determine ssh gateway for '#{hostname}' from ssh config template: #{ssh_proxy.command_line_template}")
            nil
          else
            # Return hostname extracted from command line template
            Chef::Log.debug("Using ssh gateway #{matchdata[1]} from ssh config")
            matchdata[1]
          end
        else
          # Return nil if we cannot find an ssh_gateway
          Chef::Log.debug("No ssh gateway found, making a direct connection")
          nil
        end
      end

      def determine_bootstrap_ip(server)
        server_ips = server.ips.select{ |ip|
          ip and not(is_loopback(ip) or is_linklocal(ip))
        }
        if server_ips.count === 1
          server_ips.first
        else
          if server_ips.all? {|ip| is_private(ip)} || config[:private_network]
            server_ips.find{|ip| is_private(ip)}
          else
            server_ips.find{|ip| not is_private(ip)}
          end
        end
      end

      private

      def server_creation_options
        o = {
            :name => @node_name,
            :dataset => config[:dataset],
            :package => config[:package]
        }.merge!(joyent_metadata)
        o.merge!(:networks => config[:networks]) if config[:networks]
        o
      end

      def validate_server_name
        # add some validation here ala knife-ec2
        unless config[:server_name] || config[:chef_node_name]
          ui.error("You have not provided a valid server or node name.")
          puts show_usage
          exit 1
        end
      end

      def joyent_metadata
        metadata = Chef::Config[:knife][:joyent_metadata] || {}
        metadata.merge!(config[:joyent_metadata])

        return {} if metadata.empty?
        Hash[metadata.map { |k, v| ["metadata.#{k}", v] }]
      end

      def _tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          banner = tcp_socket.gets
          puts ui.color("SSHD accepting connections on #{hostname}: banner is #{banner}")
          Chef::Log.debug("SSHD accepting connections on #{hostname}: banner is #{banner}")
          true
        else
          false
        end
      rescue SocketError,
             IOError,
             Errno::ETIMEDOUT,
             Errno::EPERM,
             Errno::ECONNREFUSED,
             Errno::ECONNRESET,
             Errno::ENETUNREACH,
             Errno::EHOSTUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

    end
  end
end

