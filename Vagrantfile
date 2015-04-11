# -*- mode: ruby -*-
# vi: set ft=ruby :

GLOBAL_FACTS = {
'balancer_ip' => '192.168.0.101',
'web_ip' => '192.168.0.102',
'db_ip' => '192.168.0.103',
}

HOSTS = {
'balancer' => {'exposed' => true, 'hostname' => 'blog.example.com', 'role' => 'balancer'},
'web' => {'exposed' => false, 'hostname' => 'web.example.com', 'role' => 'web'},
'db' => {'exposed' => false, 'hostname' => 'db.example.com', 'role' => 'db'},
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

  HOSTS.each do |host, host_info|
    config.vm.define host do |vm|
      vm.vm.hostname = host_info['hostname']
      if host_info['exposed']
        vm.vm.network 'forwarded_port', guest: 80, host:80
      end
      vm.vm.network 'private_network', ip: GLOBAL_FACTS["#{host}_ip"]
      tmp_shell_cmd = shell_cmd
      tmp_shell_cmd << "echo 'instance_role=#{host_info['role']}' > /etc/facter/facts.d/fact_role.txt; "
      config.vm.provision :shell do |shell|
        shell.inline = "#{tmp_shell_cmd}"
      end
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
