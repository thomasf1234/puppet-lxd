class lxd::state::absent {
  service { 'lxd':
    ensure => 'stopped',
    enable => false
  }
  package {'lxd':
    ensure  => 'purged',
    require => Service['lxd']
  }

  package {'zfsutils-linux':
    ensure => 'latest'
  }

  group {'lxd':
    ensure => 'absent'
  }
}
