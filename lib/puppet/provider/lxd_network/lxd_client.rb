require 'lxd-client'

Puppet::Type.type(:lxd_network).provide(:lxd_client) do 
  desc "LXD Client Support"  

  def initialize(value = {})
    super(value)
    @lxc = LxdClient::Service.new(Facter.value(:lxd)['socket'])
  end

  def self.instances
    lxc = LxdClient::Service.new
    network_names = lxc.networks
    networks = []
    resources = []

    network_names.each do |network_name|
      network = lxc.network(network_name)
      networks << network
    end

    networks.each do |network|
      resource = new(
        ensure: :present,
        name: network['name'],
        config: network['config'],
        description: network['description'],
        type: network['type'],
        used_by: network['used_by'],
        managed: network['managed'],
        status: network['status'],
        locations: network['locations']
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
    network_hash = {
      name: @resource.name,
    }

    network_properties = @resource.properties.select do |property|
      [
        :config, 
        :description,
        :type,
        :used_by,
        :managed,
        :status,
        :locations
      ].include?(property.name)
    end

    network_properties.each do |property|
      network_hash[property.name] = property.value
    end

    @lxc.network_create(network_hash)
  end  
  
  def destroy 
    @lxc.network_delete(@resource[:name])
  end  
   
  def exists? 
    @lxc.networks.include?(@resource[:name])
  end 

  def replace
    network_hash = {
      name: @resource.name,
    }

    network_properties = @resource.properties.select do |property|
      [
        :config, 
        :description,
        :type,
        :used_by,
        :managed,
        :status,
        :locations
      ].include?(property.name)
    end

    network_properties.each do |property|
      network_hash[property.name] = property.value
    end

    @lxc.network_replace(@resource[:name], network_hash)
  end

  #properties
  def description
    @property_hash[:description]  
  end

  def description=(value)
    replace
  end

  def config
    @property_hash[:config]  
  end

  def config=(value)
    replace
  end

  def type
    @property_hash[:type]  
  end

  def type=(value)
    replace
  end

  def used_by
    @property_hash[:used_by]  
  end

  def used_by=(value)
    replace
  end

  def managed
    @property_hash[:managed]  
  end

  def managed=(value)
    replace
  end

  def status
    @property_hash[:status]  
  end

  def status=(value)
    replace
  end

  def locations
    @property_hash[:locations]  
  end

  def locations=(value)
    replace
  end
end