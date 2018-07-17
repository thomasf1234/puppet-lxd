class lxd::state::present {
  $package_ensure = lookup('lxd::package_ensure')
  $service_ensure = lookup('lxd::service_ensure')
  $service_enable = lookup('lxd::service_enable')

  package {'lxd':
    ensure  => $package_ensure,
    require => Package['zfsutils-linux']
  }

  group {'lxd':
    ensure => 'present'
  }

  service { 'lxd':
    ensure => $service_ensure,
    enable => $service_enable
  }
}
