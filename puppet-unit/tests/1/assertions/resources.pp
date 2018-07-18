class puppet_unit::example {
  group {'lxd':
    ensure => 'present'
  }

  package {'lxd':
    ensure => 'present'
  }

  service {'lxd':
    ensure => 'running'
  }

  lxd_profile { 'basic':
    ensure      => 'present',
    config      => {
      'boot.autostart'          => 'true',
      'boot.autostart.priority' => '100',
      'environment.http_proxy'  => '',
      'limits.cpu'              => '2',
      'limits.memory'           => '500MB',
      'limits.memory.swap'      => 'false'
    },
    description => 'Basic LXD profile',
    devices     => {
      'eth0' => {
        'name'    => 'eth0',
        'nictype' => 'bridged',
        'parent'  => 'lxdbr0',
        'type'    => 'nic'
      },
      'root' => {
        'path' => '/',
        'pool' => 'default',
        'size' => '2GB',
        'type' => 'disk'
      }
    }
  }
}

include puppet_unit::example
