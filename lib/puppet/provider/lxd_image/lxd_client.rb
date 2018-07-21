require 'lxd-client'
require 'digest'
require 'tmpdir'
require 'net/http'
require 'uri'
require 'pry'

Puppet::Type.type(:lxd_image).provide(:lxd_client) do 
  desc "LXD Client Support"  

  def initialize(value = {})
    super(value)
    @lxc = LxdClient::Service.new(Facter.value(:lxd)['socket'])
  end

  def self.instances
    lxc = LxdClient::Service.new(Facter.value(:lxd)['socket'])
    image_names = lxc.images
    images = []
    resources = []

    image_names.each do |image_name|
      image = lxc.image(image_name)
      images << image
    end

    images.each do |image|
      resource = new(
      ensure: :present,
        name: image['fingerprint'],
        aliases: image['aliases'], 
        architecture: image['architecture'],
         auto_update: image['auto_update'], 
         cached: image['cached'], 
         created_at: image['created_at'], 
         expires_at: image['expires_at'], 
         filename: image['filename'], 
         last_used_at: image['last_used_at'], 
         properties: image['properties'], 
         public: image['public'], 
         size: image['size'], 
         uploaded_at: image['uploaded_at']
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
    image_hash = {
      sha256_fingerprint: @resource.name,
      properties: {},
      public: false
    }

    image_properties = @resource.properties.select do |property|
      [
        :description,
        :source,
        :properties,
        :public
      ].include?(property.name)
    end

    image_properties.each do |property|
      image_hash[property.name] = property.value
    end
    
    source = image_hash[:properties]['source']

    if uri?(source)
      Puppet.debug("source is a URL")
      url = source 

      Dir.mktmpdir do |dir|
        filename = File.basename(url)
        local_path = File.join(dir, filename)
        download_file(url, local_path)
        upload_image(local_path, image_hash)
      end
    else
      Puppet.debug("source is a local path")
      local_path = source
      upload_image(local_path, image_hash) 
    end
  end  
  
  def destroy 
    @lxc.image_delete(@resource[:name])
  end  
   
  def exists? 
    @lxc.images.include?(@resource[:name])
  end 

  #properties
  def aliases
    @property_hash[:aliases]
  end
  
  def architecture
    @property_hash[:architecture]
  end
  
  def auto_update
    @property_hash[:auto_update]
  end
  
  def cached
    @property_hash[:cached]
  end
  
  def created_at
    @property_hash[:created_at]
  end
  
  def expires_at
    @property_hash[:expires_at]
  end
  
  def filename
    @property_hash[:filename]
  end

  def filename=
    @property_hash[:filename]
  end
  
  def last_used_at
    @property_hash[:last_used_at]
  end
  
  def properties
    @property_hash[:properties]
  end
  
  def public
    @property_hash[:public]
  end
  
  def size
    @property_hash[:size]
  end
  
  def uploaded_at
    @property_hash[:uploaded_at]
  end

  # utils
  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end

  def download_file(url, path)
    uri = URI(url)
    Puppet.debug("starting download of #{url} to #{path}")

    total_bytesize = 0
    Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request) do |response|
        File.open(path, 'w') do |io|
          response.read_body do |chunk|
            total_bytesize += chunk.bytesize
            Puppet.debug("downloaded #{total_bytesize} bytes total")
            io.write(chunk)
          end
        end
      end
      Puppet.debug("finished downloading #{total_bytesize} bytes total")
    end
  end

  def upload_image(local_path, image_hash)
    if File.exist?(local_path)     
      sha256 = Digest::SHA256.file(local_path).hexdigest

      Puppet.debug("Verifying fingerprint of #{local_path}")
      if sha256 == image_hash[:sha256_fingerprint]
        Puppet.debug("Uploading #{image_hash[:sha256_fingerprint]} from #{local_path}")
        @lxc.image_upload(local_path, 
          sha256: image_hash[:sha256_fingerprint],
           properties: image_hash[:properties], 
           is_public: image_hash[:public])
      else
        raise ArgumentError.new("fingerprint #{image_hash[:sha256_fingerprint]} does not match sha256 of source #{sha256} ")
      end
    else
      raise ArgumentError.new("File #{local_path} not found")  
    end
  end
end