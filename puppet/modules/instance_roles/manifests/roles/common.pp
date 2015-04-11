class instance_roles::roles::common {
  # Common Role
  File { 
    owner => 0, 
    group => 0, 
    mode => 0644
  }

  file { '/etc/motd':
    content => "Welcome to your Vagrant-built virtual machine!
                Managed by Puppet.
                The role of this machine is ${instance_role}\n"
  }
}

