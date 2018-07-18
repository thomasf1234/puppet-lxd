require 'lxd-client'

Puppet::Type.newtype(:lxd_storage_pool) do
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
    desc 'The name of the storage_pool'
    newvalues(%r{^\S+$})
  end

  newproperty(:config) do
    desc 'The storage_pool config'
    validate do |value| 
      unless value.kind_of?(Hash)
         raise ArgumentError.new("config must be a hash")
      end 
    end
  end

  newproperty(:description) do
    desc 'The description of the profile'
    newvalues(/.*/)
  end

  newproperty(:driver) do
    desc 'The driver'
    newvalues(/.+/)
  end

  newproperty(:locations, array_matching: :all) do
    desc 'The locations'
  end

  newproperty(:status) do
    desc 'The status of the profile'
    newvalues(/.*/)
  end

  newproperty(:used_by) do
    desc 'The used_by of the storage_pool'
  end
end
  