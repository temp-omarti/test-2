# -*- mode: ruby -*-
# vi: set ft=ruby :

# Info of all the global facts that will 
# be injected on all the machines
GLOBAL_FACTS = {
'balancer_ip' => '192.168.0.101',
'web_ip' => '192.168.0.102',
'db_ip' => '192.168.0.103',
}

# Info of all the hosts we want to create
HOSTS = {
'db' => {'exposed' => false, 'hostname' => 'db.example.com', 'role' => 'db'},
'web' => {'exposed' => false, 'hostname' => 'web.example.com', 'role' => 'web'},
'balancer' => {'exposed' => true, 'hostname' => 'blog.example.com', 'role' => 'balancer'},
}

Vagrant.configure(2) do |config|

  # Trusty 64 bits box for all the machines
  config.vm.box = 'trusty64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  # We are passing facts writing to file 
  # because puppet.facter is not working
  shell_cmd = ''
  shell_cmd << 'mkdir -p /etc/facter/facts.d/; '
  GLOBAL_FACTS.each do |k,v|
    shell_cmd << "echo '#{k}=#{v}' > /etc/facter/facts.d/fact_#{k}.txt; "
  end

  # Generating all the info for the hosts
  HOSTS.each do |host, host_info|
    config.vm.define host do |vm|
      # Hostnames and networking
      vm.vm.hostname = host_info['hostname']
      if host_info['exposed']
        vm.vm.network 'forwarded_port', guest: 80, host:80
      end
      vm.vm.network 'private_network', ip: GLOBAL_FACTS["#{host}_ip"]

      # Shell comands to provision
      # We are going to install all the puppet modules
      # not related directly with the project
      tmp_shell_cmd = ''
      tmp_shell_cmd << shell_cmd
      tmp_shell_cmd << "echo 'instance_role=#{host_info['role']}' > /etc/facter/facts.d/fact_role.txt; "
      # puppet mysql module needs a newer stdlib library
      tmp_shell_cmd << 'puppet module install --force puppetlabs-stdlib;'
      # puppet haproxy module needs ripienaar/concat module
      tmp_shell_cmd << 'if  ! puppet module list | grep ripienaar-concat > /dev/null ; then puppet module install ripienaar/concat; fi;'
      tmp_shell_cmd << 'if  ! puppet module list | grep puppetlabs-apt  > /dev/null ; then puppet module install puppetlabs/apt; fi;'
      vm.vm.provision :shell do |shell|
        shell.inline = "#{tmp_shell_cmd}"
      end

      # Syncing hieradata directory
      vm.vm.synced_folder 'puppet/hieradata', '/etc/puppet/hieradata'
      # Puppet provisioning for all the machines
      vm.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'
        puppet.module_path = [ 'puppet/modules' ]
        puppet.hiera_config_path = 'puppet/hiera.yaml'
        # puppet facter is not working
        #puppet.facter = {
        #}
      end
    end
  end
end
