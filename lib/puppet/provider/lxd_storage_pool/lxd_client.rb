require 'lxd-client'

Puppet::Type.type(:lxd_storage_pool).provide(:lxd_client) do 
  desc "LXD Client Support"  

  def initialize(value = {})
    super(value)
    @lxc = LxdClient::Service.new(Facter.value(:lxd)['socket'])
  end

  def self.instances
    lxc = LxdClient::Service.new
    storage_pool_names = lxc.storage_pools
    storage_pools = []
    resources = []

    storage_pool_names.each do |storage_pool_name|
      storage_pool = lxc.storage_pool(storage_pool_name)
      storage_pools << storage_pool
    end

    storage_pools.each do |storage_pool|
      resource = new(
        ensure: :present,
        name: storage_pool['name'],
        config: storage_pool['config'],
        description: storage_pool['description'],
        driver: storage_pool['driver'],
        locations: storage_pool['locations'],
        status: storage_pool['status'],
        used_by: storage_pool['used_by']        
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
    storage_pool_hash = {
      name: @resource.name,
    }

    storage_pool_properties = @resource.properties.select do |property|
      [ 
        :config, 
        :description, 
        :driver, 
        :locations, 
        :status, 
        :used_by
      ].include?(property.name)
    end

    storage_pool_properties.each do |property|
      storage_pool_hash[property.name] = property.value
    end

    @lxc.storage_pool_create(storage_pool_hash)
  end  
  
  def destroy 
    @lxc.storage_pool_delete(@resource[:name])
  end  
   
  def exists? 
    @lxc.storage_pools.include?(@resource[:name])
  end 

  def replace
    storage_pool_hash = {
      name: @resource.name,
    }

    storage_pool_properties = @resource.properties.select do |property|
      [ 
        :config, 
        :description, 
        :driver, 
        :locations, 
        :status, 
        :used_by
      ].include?(property.name)
    end

    storage_pool_properties.each do |property|
      storage_pool_hash[property.name] = property.value
    end

    @lxc.storage_pool_replace(@resource[:name], storage_pool_hash)
  end

  #properties
  def config
    @property_hash[:config]  
  end

  def config=(value)
    replace
  end

  def description
    @property_hash[:description]  
  end

  def description=(value)
    replace
  end

  def driver
    @property_hash[:driver]  
  end

  def driver=(value)
    replace
  end

  def locations
    @property_hash[:locations]  
  end

  def locations=(value)
    replace
  end

  def status
    @property_hash[:status]  
  end

  def status=(value)
    replace
  end

  def used_by
    @property_hash[:used_by]  
  end

  def used_by=(value)
    replace
  end
end