require File.expand_path(File.dirname(__FILE__) + '/base')

module KnifeJoyent
  class JoyentServerCreate < Chef::Knife

    include KnifeJoyent::Base

    deps do
      require 'fog'
      require 'readline'
      require 'chef/json_compat'
      require 'chef/knife/bootstrap'
      require 'ipaddr'
      Chef::Knife::Bootstrap.load_deps
    end
    
    banner 'knife joyent server create (options)'

    # mixlib option parsing
    option :name,
      :long => '--name <name>',
      :description => 'name for this machine'

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

    option :private_network,
      :long => "--private-network",
      :description => "Use the private IP for bootstrapping rather than the public IP",
      :boolean => true,
      :default => false

    option :ssh_user,
      :short => "-x USERNAME",
      :long => "--ssh-user USERNAME",
      :description => "The ssh username",
      :default => "root"

    option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity-file IDENTITY_FILE",
      :description => "The SSH identity file used for authentication"

    option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node"

    option :prerelease,
      :long => "--prerelease",
      :description => "Install the pre-release chef gems"

    option :distro,
      :short => "-d DISTRO",
      :long => "--distro DISTRO",
      :description => "Bootstrap a distro using a template",
      :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
      :default => "chef-full"
      
    option :no_host_key_verify,
      :long => "--no-host-key-verify",
      :description => "Disable host key verification",
      :boolean => true,
      :default => false

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

    # wait for ssh to come up
    def tcp_test_ssh(hostname)
      tcp_socket = TCPSocket.new(hostname, 22)
      readable = IO.select([tcp_socket], nil, nil, 5)
      if readable
        Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
        yield
        true
      else
        false
      end
    rescue Errno::ETIMEDOUT
      false
    rescue Errno::EPERM
      false
    rescue Errno::ECONNREFUSED
      sleep 2
      false
    rescue Errno::EHOSTUNREACH
      sleep 2
      false
    ensure
      tcp_socket && tcp_socket.close
    end


    # Run Chef bootstrap script
    def bootstrap_for_node(server, bootstrap_ip_address)
      bootstrap = Chef::Knife::Bootstrap.new
      Chef::Log.debug("Bootstrap name_args = [ #{bootstrap_ip_address} ]")
      bootstrap.name_args = [ bootstrap_ip_address ]
      Chef::Log.debug("Bootstrap run_list = #{config[:run_list]}")
      bootstrap.config[:run_list] = config[:run_list]
      Chef::Log.debug("Bootstrap ssh_user = #{config[:ssh_user]}")
      bootstrap.config[:ssh_user] = config[:ssh_user]
      Chef::Log.debug("Bootstrap identity_file = #{config[:identity_file]}")
      bootstrap.config[:identity_file] = config[:identity_file]
      Chef::Log.debug("Bootstrap chef_node_name = #{config[:chef_node_name]}")
      bootstrap.config[:chef_node_name] = config[:chef_node_name] || server.id
      Chef::Log.debug("Bootstrap prerelease = #{config[:prerelease]}")
      bootstrap.config[:prerelease] = config[:prerelease]
      Chef::Log.debug("Bootstrap distro = #{config[:distro]}")
      bootstrap.config[:distro] = config[:distro]
      #Chef::Log.debug("Bootstrap use_sudo = #{config[:use_sudo]}")
      #bootstrap.config[:use_sudo] = true
      Chef::Log.debug("Bootstrap environment = #{config[:environment]}")
      bootstrap.config[:environment] = config[:environment]
      Chef::Log.debug("Bootstrap no_host_key_verify = #{config[:no_host_key_verify]}")
      bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]

      bootstrap
    end

    # Go
    def run
      puts ui.color("Creating machine #{config[:chef_node_name]}", :cyan)
      begin
        server = self.connection.servers.create(:dataset => config[:dataset],
                                            :package => config[:package],
                                            :name => config[:name])
      server.wait_for { print "."; ready? }                                      
      rescue => e
        Chef::Log.debug("e: #{e}")
        if e.response && e.response.body.kind_of?(String)
          error = MultiJson.decode(e.response.body)
          puts ui.error(error['message'])
          exit 1
        else
          raise
        end
      end

      puts ui.color("Created machine:", :cyan)
      msg_pair("ID", server.id.to_s)
      msg_pair("Name", server.name)
      msg_pair("State", server.state)
      msg_pair("Type", server.type)
      msg_pair("Dataset", server.dataset)
      msg_pair("IP's", server.ips)
      pubip = server.ips.find{|ip| ip and not (is_loopback(ip) or is_private(ip) or is_linklocal(ip))}
      puts ui.color("attempting to bootstrap on #{pubip}", :cyan)

      # pubip = server.ips.find{|ip| ip and not (is_loopback(ip) or is_private(ip) or is_linklocal(ip))}

      bootstrap_ip_addresses = server.ips.select{|ip| ip and not (is_loopback(ip) or is_linklocal(ip))}

      if bootstrap_ip_addresses.count == 1
        bootstrap_ip_address = bootstrap_ip_addresses.first
      else
        if config[:private_network]
          bootstrap_ip_address = bootstrap_ip_addresses.find{|ip| is_private(ip)}
        else
          bootstrap_ip_address = bootstrap_ip_addresses.find{|ip| not is_private(ip)}
        end
      end
      Chef::Log.debug("Bootstrap IP Address #{bootstrap_ip_address}")
      if bootstrap_ip_address.nil?
        ui.error("No IP address available for bootstrapping.")
        exit 1
      end

      puts ui.color("attempting to bootstrap on #{bootstrap_ip_address}", :cyan)

      print(".") until tcp_test_ssh(bootstrap_ip_address) {
        sleep 1
        puts("done")
      }
      bootstrap_for_node(server, bootstrap_ip_address).run
      exit 0
    end
    
    def msg_pair(label, value = nil)
      if value && !value.empty?
        puts "#{ui.color(label, :cyan)}: #{value}"
      end
    end
  end
end
