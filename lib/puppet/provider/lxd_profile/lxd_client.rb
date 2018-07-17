require 'lxd-client'

Puppet::Type.type(:lxd_profile).provide(:lxd_client) do 
  desc "LXD Client Support"  

  def initialize(value = {})
    super(value)
    @lxc = LxdClient::Service.new
  end

  def self.instances
    lxc = LxdClient::Service.new
    profile_names = lxc.profiles
    profiles = []
    resources = []

    profile_names.each do |profile_name|
      profile = lxc.profile(profile_name)
      profiles << profile
    end

    profiles.each do |profile|
      resource = new(
        ensure: :present,
        name: profile['name'],
        description: profile['description'],
        config: profile['config'],
        devices: profile['devices'],
        used_by: profile['used_by']
      )

      resources << resource
    end

    resources
  end

  def self.prefetch(resources)
    _instances = instances
    resources.each_key do |resource_name|
      provider = _instances.find { |_instance| _instance.name == resource_name }

      if !provider.nil?
        resources[resource_name].provider = provider
      end
    end
  end

  #ensurable
  def create 
    profile_hash = {
      name: @resource.name,
    }

    profile_properties = @resource.properties.select do |property|
      [:config, :description, :devices, :used_by].include?(property.name)
    end

    profile_properties.each do |property|
      profile_hash[property.name] = property.value
    end

    @lxc.profile_create(profile_hash)
  end  
  
  def destroy 
    @lxc.profile_delete(@resource[:name])
  end  
   
  def exists? 
    @lxc.profiles.include?(@resource[:name])
  end 

  #properties
  def description
    @property_hash[:description]  
  end

  def description=(value)
    @lxc.profile_update(@resource[:name], { description: value })
  end

  def config
    @property_hash[:config]  
  end

  def config=(value)
    @lxc.profile_update(@resource[:name], { config: value })
  end

  def used_by
    @property_hash[:used_by]  
  end

  def used_by=(value)
    @lxc.profile_update(@resource[:name], { used_by: value })
  end

  def devices
    @property_hash[:devices]  
  end

  def devices=(value)
    @lxc.profile_update(@resource[:name], { devices: value })
  end
end