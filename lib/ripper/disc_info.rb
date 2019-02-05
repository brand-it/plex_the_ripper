class DiscInfo
  extend BashHelper
  include BashHelper
  attr_accessor(
    :content, :device_identifier, :mount_point,
    :size, :volume_name, :ejected
  )

  def initialize(hash_map = {})
    self.content = hash_map['Content']
    self.device_identifier = hash_map['DeviceIdentifier']
    self.mount_point = hash_map['MountPoint']
    self.size = hash_map['Size'].to_i
    self.volume_name = hash_map['VolumeName']
  end

  def describe
    "#{device_identifier} | #{volume_name}"
  end

  def dev
    "/dev/#{device_identifier}"
  end

  def self.list_discs
    discs = request_all_discs
    discs.map do |disc|
      hash_map = {}
      keys = disc.xpath('key')
      values = disc.xpath('string|integer')
      keys.each_with_index do |key, index|
        next if values[index].nil?

        hash_map[key.inner_html] = values[index].inner_html
      end
      DiscInfo.new(hash_map)
    end
  end

  def self.request_all_discs
    response = capture3('diskutil list -plist external physical')
    doc = Nokogiri::XML(response.stdout_str)
    doc.xpath("//key[text() = 'AllDisks']/parent::*/array/dict")
  end

  def reload
    disc_info = self.class.list_discs.find { |d| d.device_identifier == device_identifier }
    disc_info ||= DiscInfo.new
    self.content = disc_info.content
    self.size = disc_info.size
    self.volume_name = disc_info.volume_name
    self
  end

  def eject
    tries = 1
    while disc_present?
      Logger.info("(#{tries}) trying to ejecting disk", rewrite: true)
      Logger.debug(capture3("diskutil eject #{device_identifier}").stdout_str)
      tries += 1
    end
    Logger.success('Was able to eject disc')
    self.content = nil
    self.size = nil
    self.volume_name = nil
  end

  def disc_present?
    reload
    size > 0
  end
end
