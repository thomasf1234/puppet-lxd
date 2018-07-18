class lxd::state::present {
  $package_ensure = lookup('lxd::package_ensure')
  $service_ensure = lookup('lxd::service_ensure')
  $service_enable = lookup('lxd::service_enable')

  package {'lxd':
    ensure  => $package_ensure,
    require => Package['zfsutils-linux']
  }

  package {'lxd-client':
    ensure  => 'latest'
  }

  group {'lxd':
    ensure => 'present'
  }

  service { 'lxd':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['lxd']
  }

  include lxd::config
  
  class { 'lxd::networks' :
    require => Class['lxd::config']
  }

  class { 'lxd::storage_pools' :
    require => Class['lxd::config']
  }

  class { 'lxd::profiles' :
    require => [
      Class['lxd::networks'],
      Class['lxd::storage_pools']
    ]
  }
}
