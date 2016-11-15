# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Number of cluster nodes (excluding the ambari server)
    cluster_size = 2
    # Base ip to use, master will have a 0 appended and then each node will add its number to it (1,2,3,4...)
    slave_base_ip = '192.168.30.'
    server_ip = '192.168.30.10'
    boxCentOS7 = 'puppetlabs/centos-7.0-64-puppet-enterprise'
    boxCentOS6 = 'puppetlabs/centos-6.6-64-puppet'
    boxUbuntuTrusty = 'ubuntu/trusty64'
    # Machine names will be a composition of the node_base_name, it's node number, and the domain_subfix
    node_base_name = "node-"
    domain_subfix = ".cluster"

    # The master will have a simple name, plus the domain_subfix
    master_hostname = 'ambarimaster'
    master_fqdn = master_hostname + domain_subfix

    # Machines' local user to provision through ambari via its private key
    user = 'root'
    # The file name of the shared ssh key for $user
    masterKey = 'master_key.pub'

    # The path where files are shared between machines
    sharePath = '/mnt/vshare'
    # The puppet folder needs to be shared explicitly for the provisioning to work
    config.vm.synced_folder 'puppet', '/puppet'
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.synced_folder 'share', sharePath, create: true

    #config.vm.box = 'puppetlabs/centos-7.0-64-puppet-enterprise'
    # puppetlabs/centos-6.6-64-puppet

    # Ambari master node provisioning.
    config.vm.define master_fqdn, primary: true do |ambariserver|
      ambariserver.vm.box = boxCentOS7
      ambariserver.vm.hostname = master_fqdn
      ambariserver.vm.network :private_network, ip: server_ip
      ambariserver.vm.network :forwarded_port, guest: 8080, host: 8080

      ambariserver.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
      end

      ambariserver.vm.provision :puppet do |puppet|
        puppet.manifests_path   = 'puppet/manifests'
        puppet.module_path      = 'puppet/modules'
        puppet.manifest_file    = 'ambariserver.pp'
        puppet.options          = '--verbose'
        puppet.facter           = {
            'master_hostname'     => master_hostname,
            'node_base_name'      => node_base_name,
            'domain_subfix'       => domain_subfix,
            'server_ip'           => server_ip,
            'slave_base_ip'       => slave_base_ip,
            'cluster_size'        => cluster_size,
            'share_path'          => sharePath,
            'shared_key'          => masterKey,
            'user'                => user
        }
      end
    end


  # Nodes provision
  1.upto(cluster_size) do |index|
    node_name = node_base_name + index.to_s + domain_subfix

    config.vm.define node_name do |node|
      node.vm.box = boxCentOS7
      node.vm.hostname = node_name
      node.vm.network :private_network, ip: "192.168.30.#{20 + index}"
      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2024]
      end

      # start the actual provisioning
      node.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file  = 'clusternode.pp'
        puppet.module_path    = 'puppet/modules'
        puppet.options        = '--verbose'
        puppet.facter         = {
          'master_hostname'     => master_hostname,
          'node_base_name'      => node_base_name,
          'domain_subfix'       => domain_subfix,
          'node_index'          => index,
          'server_ip'           => server_ip,
          'slave_base_ip'       => slave_base_ip,
          'cluster_size'        => cluster_size,
          'share_path'          => sharePath,
          'shared_key'          => masterKey,
          'user'                => user
        }
      end
    end # node
  end # nodes provision

end
