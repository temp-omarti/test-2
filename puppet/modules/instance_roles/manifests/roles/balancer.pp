class instance_roles::roles::balancer {
  # Role for the balancer
  class { 'haproxy':
    defaults_options => {
      log      => 'global',
      mode     =>   'http',
      option   => [
        'httplog',
        'dontlognull',
        'redispatch',
      ],
      retries  => '3',
      maxconn  => '20000',
      contimeout => '20000',
      clitimeout => '6000',
      srvtimeout => '6000',
    }
  }
  haproxy::listen { 'puppet00':
    collect_exported => false,
    ipaddress        => '*',
    ports            => '80',
    options           => {
      'balance' => 'roundrobin',
      'option'  => ['forwardfor'],
    },
  }

  haproxy::balancermember { 'master00':
    listening_service => 'puppet00',
    server_names      => 'web.example.com',
    ipaddresses       => $web_ip,
    ports             => '80',
    options           => 'check',
  }
}
