require 'lxd-client'

Puppet::Type.type(:lxd_config_entry).provide(:lxd_client) do 
  desc "LXD Client Support"  

  def initialize(value = {})
    super(value)
    @lxc = LxdClient::Service.new(Facter.value(:lxd)['socket'])
  end

  def self.instances
    lxc = LxdClient::Service.new
    config_entries = lxc.config['config']
    resources = []

    config_entries.each do |key, value|
      resource = new(
        ensure: :present,
        name: key,
        value: value
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
    config_value_property = @resource.properties.detect do |property|
      property.name == :value
    end

    config_hash = {
      @resource.name => config_value_property.value
    }

    @lxc.config_update({ config: config_hash })
  end  
  
  def destroy 
    config_hash = { @resource[:name] => nil }
    @lxc.config_update({ config: config_hash })
  end  
   
  def exists? 
    @lxc.config['config'].keys.include?(@resource[:name])
  end 
  
  #properties
  def value
    @property_hash[:value]  
  end

  def value=(_value)
    config_hash = {
      @resource.name => value
    }

    @lxc.config_update({ config: config_hash })
  end
end