module KnifeJoyent
  class JoyentServerCreate < Chef::Knife

    include KnifeJoyent::Base

    deps do
      require 'chef/knife/bootstrap'
      Chef::Knife::Bootstrap.load_deps
      require 'fog'
      require 'socket'
      require 'net/ssh/multi'
      require 'readline'
      require 'chef/json_compat'
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

    option :environment,
      :short => "-E Environment",
      :long => "--environment ENVIRONMENT",
      :description => "Assign an environment to Chef Node",
      :proc => Proc.new { |e| Chef::Config[:environment][:distro] = e },
      :default => "_default"

    option :no_host_key_verify,
      :long => "--no-host-key-verify",
      :description => "Disable host key verification",
      :boolean => true,
      :default => false

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
    def bootstrap_for_node(server)
      bootstrap = Chef::Knife::Bootstrap.new
      Chef::Log.debug("Bootstrap name_args = [ #{server.ips.last} ]")
      bootstrap.name_args = [ server.ips.last ]
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
      begin
        server = self.connection.servers.create(:dataset => config[:dataset],
                                            :package => config[:package],
                                            :name => config[:name])

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

      puts ui.color("Created machine: #{server.id}", :cyan)
      puts ui.color("attempting to bootstrap on #{server.ips.last}", :cyan)
    
      print(".") until tcp_test_ssh(server.ips.last) {
        sleep 1
        puts("done")
      }
      bootstrap_for_node(server).run
      exit 0
    end

  end
end
