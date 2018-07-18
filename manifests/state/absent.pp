class lxd::state::absent {
  service { 'lxd':
    ensure => 'stopped',
    enable => false
  }
  
  package {'lxd':
    ensure  => 'purged',
    require => Service['lxd']
  }

  package {'lxd-client':
    ensure  => 'purged',
    require => Package['lxd']
  }

  group {'lxd':
    ensure => 'absent',
    require => Package['lxd']
  }

  file { '/var/lib/lxd' :
    ensure  => 'absent',
    force   => true,
    backup  => false,
    require => Package['lxd']
  }
}
