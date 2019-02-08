class DiscInfo
  attr_accessor(
    :content, :device_identifier, :mount_point,
    :size, :volume_name, :ejected
  )

  class << self
    def list_discs
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

    def request_all_discs
      response = Shell.capture3('diskutil list -plist external physical')
      doc = Nokogiri::XML(response.stdout_str)
      doc.xpath("//key[text() = 'AllDisks']/parent::*/array/dict")
    end
  end

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

  def details
    return @details if @details

    get_disk_info_command = [
      Config.configuration.makemkvcon_path,
      'info',
      Config.configuration.disk_source,
      "--minlength=#{Config.configuration.minlength}",
      '-r'
    ].join(' ')
    Logger.info(
      "Inspecting #{Config.configuration.disk_source} with min length "\
      "#{Config.configuration.minlength} seconds", delayed: true
    )
    @details = parse_disk_info_string(
      Shell.system!(get_disk_info_command).stdout_str
    )
    @details
  end

  def titles
    return @titles if @titles

    @titles = Set.new
    details.each do |detail|
      @titles.merge(detail[:titles])
    end
    @titles
  end

  def reload
    disc_info = self.class.list_discs.find { |d| d.device_identifier == device_identifier }
    disc_info ||= DiscInfo.new
    self.content = disc_info.content
    self.size = disc_info.size
    self.volume_name = disc_info.volume_name
    @details = nil
    @titles = nil
    self
  end

  def eject
    tries = 1
    while disc_present?
      Logger.info("(#{tries}) trying to ejecting disk", rewrite: true)
      Logger.debug(Shell.capture3("diskutil eject #{device_identifier}").stdout_str)
      tries += 1
    end
    Logger.success('Was able to eject disc')
    self.content = nil
    self.size = nil
    self.volume_name = nil
    @details = nil
    @titles = nil
  end

  def disc_present?
    reload
    size > 0
  end

  private

  def parse_disk_info_string(disk_info_string)
    lines = disk_info_string.split("\n")
    groups = []
    lines.each do |line|
      match = line.delete('"').match(/(\A.*?):(.*)/)
      values = match[2].split(',')
      case match[1]
      when 'TINFO'
        dup_group = groups.find do |group|
          group[:string] == values[3] && group[:integer_one] == values[1].to_i
        end
        if dup_group
          dup_group[:titles].add(values[0].to_i)
        else
          groups << {
            integer_one: values[1].to_i,
            integer_two: values[2].to_i,
            string: values[3].to_s,
            titles: Set[values[0].to_i]
          }
        end
      when 'SINFO'
        dup_group = groups.find do |group|
          group[:string] == values[4].to_s
        end
        if dup_group
          dup_group[:titles].add(values[0].to_i)
        else
          groups << {
            integer_one: values[2].to_i,
            integer_two: values[3].to_i,
            string: values[4].to_s,
            titles: Set[values[0].to_i]
          }
        end
      end
    end
    if groups.size.zero?
      Logger.error('No disk information found', delayed: true)
      Logger.error(disk_info_string, delayed: true)
    end
    groups
  end
end
