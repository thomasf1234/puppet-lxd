require 'lxd-client'

Puppet::Type.newtype(:lxd_image) do
    desc <<-DESC
  Native type for managing LXD images
  
  @example query all defined networks
   $ puppet resource lxd_image
  
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
    desc 'The sha256 fingerprint of the image'
    newvalues(%r{^\S+$})
  end

  newproperty(:aliases, array_matching: :all) do
    desc 'The aliases'
  end

  newproperty(:architecture) do
    desc 'The container architecture'
    newvalues(/.+/)
  end

  newproperty(:auto_update) do
    desc 'Whether or not the image auto updates'
    validate do |value| 
      unless (value.kind_of?(TrueClass) || value.kind_of?(FalseClass))
         raise ArgumentError.new("auto_update must be a boolean")
      end 
    end
  end

  newproperty(:cached) do
    desc 'Whether the image should be cached when spawing containers'
    validate do |value| 
      unless (value.kind_of?(TrueClass) || value.kind_of?(FalseClass))
         raise ArgumentError.new("cached must be a boolean")
      end 
    end
  end

  newproperty(:created_at) do
    desc 'The created time of the image'
    newvalues(/.*/)
  end

  newproperty(:expires_at) do
    desc 'The expriry time of the image'
    newvalues(/.*/)
  end

  newproperty(:filename) do
    desc 'The filename used when exporting the image'
    newvalues(/.*/)
  end
  
  newproperty(:last_used_at) do
    desc 'The last time the image was used'
    newvalues(/.*/)
  end

  newproperty(:properties) do
    desc 'The image properties'
    validate do |value| 
      unless value.kind_of?(Hash)
         raise ArgumentError.new("properties must be a hash")
      end 
    end
  end

  newproperty(:public) do
    desc 'if the image is public'
    validate do |value| 
      unless (value.kind_of?(TrueClass) || value.kind_of?(FalseClass))
         raise ArgumentError.new("public must be a boolean")
      end 
    end
  end

  newproperty(:size) do
    desc 'The image size in bytes'
    newvalues(/.*/)
  end

  newproperty(:uploaded_at) do
    desc 'The uploaded time of the image'
    newvalues(/.*/)
  end
end
  