Exec { path => [ '/usr/local/sbin/', '/usr/local/bin/', '/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/' ] }

node 'default' {
  include lxd

  package { 'zfsutils-linux' :
    ensure => 'latest'
  }
}
