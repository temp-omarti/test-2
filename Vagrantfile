# -*- mode: ruby -*-
# vi: set ft=ruby :

GLOBAL_FACTS = {
"balancer_ip" => "192.168.0.101",
"web_ip" => "192.168.0.102",
"db_ip" => "192.168.0.103",
}

Vagrant.configure(2) do |config|

  # Trusty 64 bits box for all the machines
  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # We are passing facts writing to file 
  # because puppet.facter is not working
  config.vm.provision :shell do |shell|
    shell_cmd = ""
    shell_cmd << "mkdir -p /etc/facter/facts.d/; "
    GLOBAL_FACTS.each do |k,v|
      puts k
      shell_cmd << "echo '#{k}=#{v}' > /etc/facter/facts.d/fact_#{k}.txt; "
    end
    shell.inline = "#{shell_cmd}"
  end

  # Puppet provisioning for all the machines
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = [ "puppet/modules" ]
    # puppet facter is not working
    #puppet.facter = {
    #}
  end

  # Database -mysql- virtual machine
  # Only private network
  config.vm.define "db" do |db|
    config.vm.hostname = "blog.example.com"
    db.vm.network "private_network", ip: GLOBAL_FACTS['db_ip']
  end

  # Web server -publify- virtual machine
  # Only private network
  config.vm.define "web" do |web|
    web.vm.network "private_network", ip: GLOBAL_FACTS['web_ip']
  end

  # Balancer -haproxy- virtual machine
  # Only private network
  config.vm.define "balancer" do |balancer|
    balancer.vm.network "forwarded_port", guest: 80, host:80
    balancer.vm.network "private_network", ip: GLOBAL_FACTS['balancer_ip']
  end
end
