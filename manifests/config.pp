class lxd::config {
  $lxd_config = lookup('lxd::config')

  create_resources('lxd_config_entry', $lxd_config)
}
