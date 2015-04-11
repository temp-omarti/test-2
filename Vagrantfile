# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Trusty 64 bits box for all the machines
  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # Database -mysql- virtual machine
  # Only private network
  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.0.103"
  end

  # Web server -publify- virtual machine
  # Only private network
  config.vm.define "web" do |web|
    web.vm.network "private_network", ip: "192.168.0.102"
  end

  # Balancer -haproxy- virtual machine
  # Only private network
  config.vm.define "balancer" do |balancer|
    balancer.vm.network "forwarded_port", guest: 80, host:80
    balancer.vm.network "private_network", ip: "192.168.0.101"
  end
end
