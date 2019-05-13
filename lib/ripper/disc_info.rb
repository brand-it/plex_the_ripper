# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# TODO: This file is a bit long. Make it smaller by splitting up it methods into more classes
class DiscInfo
  include ArrayHelper
  Detail = Struct.new(:id, :code_one, :code_two, :value)

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

    @details = parse_disk_info_string(CreateMKV.disc_info)
  end

  def titles
    details.keys
  end

  def reload
    disc_info = self.class.list_discs.find { |d| d.device_identifier == device_identifier }
    disc_info ||= DiscInfo.new
    self.content = disc_info.content
    self.size = disc_info.size
    self.volume_name = disc_info.volume_name
    @details = nil
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
    size.positive?
  end

  # the Title Seconds are in the same order as the titles.
  # This means if you are looking for a titles seconds just use this code below
  # - examples -
  #    title_seconds[titles.find_index(12)]
  def title_seconds
    return @title_seconds if @title_seconds

    @title_seconds = {}

    details.each do |title, information|
      detail = information.find { |info| info.code_one == 9 }
      if detail.nil?
        raise(
          Plex::Ripper::Terminate,
          "failed to resolve title the run time for #{title}. "\
          'This might be because of a bad disc or more then likey a bug in this code'
        )
      end
      title_seconds[title] = convert_formatted_time_to_seconds(detail.value)
    end
    @title_seconds
  end

  # build a sort of user reable string of details and information
  def friendly_details
    return @friendly_titles if @friendly_titles

    @friendly_titles = []
    details.each do |title, detail|
      length = detail.find { |d| d.code_one == 9 }.value
      name = detail.find { |d| d.code_one == 2 }&.value
      file_size = detail.find { |d| d.code_one == 10 }.value
      file_name = detail.find { |d| d.code_one == 27 }.value
      @friendly_titles.push(
        title: title,
        name: "#{name || '?unknown name?'} Runtime (#{length}) Size (#{file_size}) File Name #{file_name.inspect}"
      )
      rescue => exception
        binding.pry
    end
    @friendly_titles
  end

  def tiles_with_length
    details.select do |title|
      title_seconds[title] <= (Config.configuration.maxlength || title_seconds[title]) &&
        title_seconds[title] >= (Config.configuration.minlength || title_seconds[title])
    end
  end

  def details_loaded?
    @details != nil
  end

  private

  def convert_formatted_time_to_seconds(formatted_time)
    hours, minutes, seconds = formatted_time.split(':').map(&:to_i)
    return 0 if hours.nil? && minutes.nil? && seconds.nil?

    minutes += (hours * 60)
    seconds += (minutes * 60)
    seconds
  end

  def parse_disk_info_string(disk_info_string) # rubocop:disable AbcSize
    lines = disk_info_string.split("\n")
    titles = {}
    lines.each do |line|
      match = line.delete('"').match(/(\A.*?):(.*)/)
      values = match[2].split(',')
      case match[1]
      when 'SINFO', 'TINFO'
        titles[values[0].to_i] ||= []
        titles[values[0].to_i].push(
          Detail.new(
            values[0].to_i,
            values[1].to_i,
            values[2].to_i,
            values[3].to_s.delete('"').delete('\\')
          )
        )
      end
    end
    if titles.size.zero?
      Logger.error(disk_info_string.gsub!('  ', ''))
      Logger.warning('No disk information found')
    end
    titles
  end
end
# rubocop:enable Metrics/ClassLength
