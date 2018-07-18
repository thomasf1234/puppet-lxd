class lxd::profiles {
  $lxd_profiles = lookup('lxd::profiles')

  create_resources('lxd_profile', $lxd_profiles)
}
