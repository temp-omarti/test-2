class instance_roles::roles::web {

  # Role for the web

  ##############################################
  # Nginx + Passenger installation and config
  ##############################################
  class { 'nginx':
    package_source => 'passenger',
    package_name => 'nginx-extras',
    http_cfg_append => {
      'passenger_root' => '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini',
      'passenger_ruby' => '/usr/bin/ruby',
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
}
