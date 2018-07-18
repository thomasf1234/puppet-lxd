require 'lxd-client'

Puppet::Type.newtype(:lxd_profile) do
    desc <<-DESC
  Native type for managing LXD profiles
  
  @example query all defined profiles
   $ puppet resource lxd_profile
  
  @example Create a lxd_profile
    lxd_profile { 'default':
      ensure      => 'present',
      description => 'Default LXD profile',
      devices     => {
        'eth0' => {
          'name' => 'eth0',
          'nictype' => 'bridged',
          'parent' => 'lxdbr0',
          'type' => 'nic'
         },
        'root' => {
          'path' => '/',
          'pool' => 'default',
          'type' => 'disk'
        }
      }
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
    desc 'The name of the profile'
    newvalues(%r{^\S+$})
  end

  newproperty(:description) do
    desc 'The description of the profile'
    newvalues(/.+/)
  end

  newproperty(:used_by) do
    desc 'The used_by of the profile'
  end

  newproperty(:config) do
    desc 'The config of the profile'
    validate do |value| 
      unless value.kind_of?(Hash)
         raise ArgumentError.new("config must be a hash")
      end 
    end
  end

  newproperty(:devices) do
    desc 'The devices of the profile'
    validate do |value| 
      unless value.kind_of?(Hash)
         raise ArgumentError.new("devices must be a hash")
      end 
    end
  end
end
  