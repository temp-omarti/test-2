class instance_roles::roles::web {

  # Role for the web

  # Variables definition
  $publify_home = '/home/publify'
  $publify_inst = "${publify_home}/publify"
  $publify_current = "${publify_inst}/current"

  ##############################################
  # Nginx + Passenger installation and config
  ##############################################
  class { 'nginx':
    package_source => 'passenger',
    package_name => 'nginx-extras',
    http_cfg_append => {
      'server_tokens'  => 'off',
      'passenger_root' => '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini',
      'passenger_ruby' => '/usr/bin/ruby',
      'passenger_max_pool_size' => '30',
      'passenger_max_requests' => '1000',
      'passenger_memory_limit' => '150',
    }
  }

  # Nginx Virtualhost with passenger
  nginx::resource::vhost {'default':
    ensure      => 'present',
    server_name => ['_'],
    listen_port => 80,
    vhost_cfg_append     => {
      'passenger_enabled'  => 'on',
      'passenger_ruby'     => '/usr/bin/ruby',
      'rails_env'          => 'production',
    },
    www_root             => '/home/publify/publify/current/public',
    use_default_location => false,
    access_log           => '/var/log/nginx/blog_access.log',
    error_log            => '/var/log/nginx/blog_error.log',
  }

  ##############################################
  # Publify Installation and deploy
  ##############################################

  # Adding publify user
  user { "publify":
    ensure     => "present",
    comment    => "Publify User",
    home       => $publify_home,
    managehome => true,
  }

  # Changing .gemrc to do not install ri and rdoc
  file { 'publify_gemrc':
    path => "${publify_home}/.gemrc",
    content => 'gem: --no-ri --no-rdoc',
  }

  User['publify']->File['publify_gemrc']

  # Changing .gemrc to do not install ri and rdoc
  file { 'root_gemrc':
    path => "/root/.gemrc",
    content => 'gem: --no-ri --no-rdoc',
  }

  # Publify directory
  file {'publify_directory':
    path     => $publify_inst,
    ensure   => 'directory',
    owner    => 'publify',
    mode     => '0755',
  }
  User['publify']->File['publify_directory']

  # Simbolic link to current publify version
  file {'publify_current':
    path   => "${publify_current}",
    ensure => 'link',
    target => 'publify-8.0.1',
    owner  => 'publify',
    mode   => '0755',
  }
  
  # Download and uncompress publify
  exec { 'get_publify':
    command => 'wget https://github.com/fdv/publify/archive/v8.0.1.tar.gz && tar -zxf v8.0.1.tar.gz && rm -rf v8.0.1.tar.gz',
    cwd     => $publify_inst,
    #path    => '/home/publify/.rbenv/plugins/ruby-build/bin:/home/publify/.rbenv/bin:/home/publify/.rbenv/shims:/bin:/usr/bin',
    user    => 'publify',
    provider    => 'shell',
  }

  # Configure publify database endpoint
  file {'publify_database':
    path    => "${publify_current}/config/database.yml",
    owner   => 'publify',
    mode    => '0644',
    content => template('instance_roles/publify/database_yml.erp'),
  }
  File['publify_directory']~>File['publify_current']~>Exec['get_publify']~>File['publify_database']

  # Do an apt-update before installing
  exec { 'apt-update':
    command => '/usr/bin/apt-get update',
  }

  # Required library for the bundle install
  package { 'zlib1g-dev':
    ensure  => latest,
  }

  # Required library for the bundle install
  package { 'libmysqlclient-dev':
    ensure  => latest,
  }

  # Bundler installation
  package { 'ruby-bundler':
    ensure  => latest,
  }

  # bundle install - will install all the libraries required by publify
  exec { 'bundle_install':
    command     => 'bundle install',
    #user        => 'publify',
    #path        => '/home/publify/.rbenv/plugins/ruby-build/bin:/home/publify/.rbenv/bin:/home/publify/.rbenv/shims:/bin:/usr/bin',
    cwd         => $publify_current,
    #environment => ["HOME=/home/publify"],
    timeout     => 0,
    provider    => 'shell',
  }

  File['root_gemrc']->Exec['bundle_install']
  File['publify_gemrc']->Exec['bundle_install']
  File['publify_database']->Exec['bundle_install']

  # DB setup on publify
  exec { 'db_setup':
    command     => 'bundle exec rake db:setup',
    user        => 'publify',
    path        => '/bin:/usr/bin:/usr/local/bin',
    cwd         => $publify_current,
    environment => ['HOME=/home/publify', 'RAILS_ENV=production'],
    provider    => 'shell',
  }

  # DB migrate on publify
  exec { 'db_migrate':
    command     => 'bundle exec rake db:migrate',
    user        => 'publify',
    path        => '/bin:/usr/bin:/usr/local/bin',
    cwd         => $publify_current,
    environment => ['HOME=/home/publify', 'RAILS_ENV=production'],
    provider    => 'shell',
  }

  # DB seed on publify
  exec { 'db_seed':
    command     => 'bundle exec rake db:seed',
    user        => 'publify',
    path        => '/bin:/usr/bin:/usr/local/bin',
    cwd         => $publify_current,
    environment => ['HOME=/home/publify', 'RAILS_ENV=production'],
    provider    => 'shell',
  }

  # Precompile assets on publify
  exec { 'assets_precompile':
    command     => 'bundle exec rake assets:precompile',
    user        => 'publify',
    path        => '/bin:/usr/bin:/usr/local/bin',
    cwd         => $publify_current,
    environment => ['HOME=/home/publify', 'RAILS_ENV=production'],
    provider    => 'shell',
  }
  Exec['apt-update']->Package['zlib1g-dev']->Package['libmysqlclient-dev']->Package['ruby-bundler']->Exec['bundle_install']->Exec['db_setup']->Exec['db_migrate']->Exec['db_seed']->Exec['assets_precompile']

}
