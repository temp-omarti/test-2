class instance_roles::roles::db {
  # Role for the db

  # MySQL installation
  class { '::mysql::server':
    root_password           => 'thisisthetest2db',
    remove_default_accounts => true, 
    restart                 => true,
    override_options        => {
      'mysqld'  => {
        'bind-address' => $db_ip,
      }
    }
  }

  # Database creation
  @mysql::db { 'publify':
    user     => 'publify',
    password => 'publify_pass',
    host     => $web_ip,
    grant    => ['ALL'],
  }
}
