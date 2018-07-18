class lxd::networks {
  $lxd_networks = lookup('lxd::networks')

  create_resources('lxd_network', $lxd_networks)
}
