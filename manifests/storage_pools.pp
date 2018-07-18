class lxd::storage_pools {
  $lxd_storage_pools = lookup('lxd::storage_pools')

  create_resources('lxd_storage_pool', $lxd_storage_pools)
}
