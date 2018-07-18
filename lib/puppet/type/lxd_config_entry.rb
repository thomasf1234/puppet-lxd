require 'lxd-client'

Puppet::Type.newtype(:lxd_config_entry) do
    desc <<-DESC
  Native type for managing LXD configuration
  
  @example query all config entries
   $ puppet resource lxd_config_entry
  
  @example Create a lxd_config_entry
    lxd_config_entry { 'core.https_address':
      ensure    => 'present',
      value      => '127.0.0.1:8444'
    }
  DESC
  
  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end
  
  autorequire(:service) { 'lxd' }
  
  newparam(:name, namevar: true) do
    desc 'The name of the config key'
    newvalues(%r{^\S+$})
  end

  newproperty(:value) do
    desc 'The value to set'
    newvalues(/.*/)
  end
end
  