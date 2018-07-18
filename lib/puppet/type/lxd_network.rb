require 'lxd-client'

Puppet::Type.newtype(:lxd_network) do
    desc <<-DESC
  Native type for managing LXD networks
  
  @example query all defined networks
   $ puppet resource lxd_network
  
  @example Create a lxd_network
    lxd_network { 'lxdbr0':
      ensure    => 'present',
      config    => {
        'ipv4.address' => '10.207.127.1/24',
        'ipv4.nat' => 'true',
        'ipv6.address' => 'fd42:ba26:625a:ffe6::1/64',
        'ipv6.nat' => 'true'
      },
      type      => 'bridge'
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
    desc 'The name of the network interface'
    newvalues(%r{^\S+$})
  end

  newproperty(:config) do
    desc 'The config of the network'
    validate do |value| 
      unless value.kind_of?(Hash)
         raise ArgumentError.new("config must be a hash")
      end 
    end
  end

  newproperty(:description) do
    desc 'The description of the network'
    newvalues(/.+/)
  end

  newproperty(:type) do
    desc 'The type of interface'
    newvalues(/.+/)
  end

  newproperty(:used_by) do
    desc 'The used_by of the network'
  end

  newproperty(:managed) do
    desc 'Whether or not LXD manages the interface'
    validate do |value| 
      unless (value.kind_of?(TrueClass) || value.kind_of?(FalseClass))
         raise ArgumentError.new("managed must be a boolean")
      end 
    end
  end

  newproperty(:status) do
    desc 'The status of the interface'
    newvalues(/.+/)
  end

  newproperty(:locations, array_matching: :all) do
    desc 'The locations'
  end
end
  