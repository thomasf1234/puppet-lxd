class lxd {
  $ensure = lookup('lxd::ensure')

  include "lxd::state::${ensure}"
}
