class puppet_unit::example {
  group {'lxd':
    ensure => 'present'
  }

  package {'lxd':
    ensure => 'present'
  }
}

include puppet_unit::example
