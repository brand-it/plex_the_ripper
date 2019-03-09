# frozen_string_literal: true

class DiscInfo
  include ArrayHelper
  Detail = Struct.new(:string, :integer_one, :integer_two, :titles) do
    include ArrayHelper

    def titles_as_ranges
      return @titles_as_ranges if @titles_as_ranges

      @titles_as_ranges = ranges_from_integers(titles.to_a)
    end
  end

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

  def consolidated_details
    return @consolidated_details if @consolidated_details

    @consolidated_details = {}
    details.each do |detail|
      @consolidated_details[detail.titles_as_ranges.first] ||= []
      @consolidated_details[detail.titles_as_ranges.first].push(detail)
    end
    @consolidated_details
  end

  def details
    return @details if @details

    @details = parse_disk_info_string(CreateMKV.disc_info)
  end

  def titles
    return @titles if @titles

    @titles = Set.new
    details.each do |detail|
      @titles.merge(detail.titles)
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

  # the Title Seconds are in the same order as the titles.
  # This means if you are looking for a titles seconds just use this code below
  # - examples -
  #    title_seconds[titles.find_index(12)]
  def title_seconds
    return @title_seconds if @title_seconds

    titles.map do |title|
      detail = details.find do |a_detail|
        a_detail.titles.include?(title) && a_detail.integer_two.zero? &&
          a_detail.string.match(/[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}/)
      end
      convert_formatted_time_to_seconds(detail.string)
    end
  end

  def tiles_with_length
    return disc_info.titles if Config.configuration.maxlength.nil?

    titles.select.with_index do |_title, index|
      title_seconds[index] <= Config.configuration.maxlength &&
        title_seconds[index] >= Config.configuration.minlength
    end
  end

  def details_loaded?
    @details != nil
  end

  private

  def convert_formatted_time_to_seconds(formatted_time)
    hours, minutes, seconds = formatted_time.split(':').map(&:to_i)
    minutes += (hours * 60)
    seconds += (minutes * 60)
    seconds
  end

  # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength
  def parse_disk_info_string(disk_info_string)
    lines = disk_info_string.split("\n")
    details = []
    lines.each do |line|
      match = line.delete('"').match(/(\A.*?):(.*)/)
      values = match[2].split(',')
      case match[1]
      when 'TINFO'
        dup_detail = details.find do |detail|
          detail.string == values[3] && detail.integer_one == values[1].to_i
        end
        if dup_detail
          dup_detail.titles.add(values[0].to_i)
        else
          details << Detail.new(
            values[3].to_s,
            values[1].to_i,
            values[2].to_i,
            Set[values[0].to_i]
          )
        end
      when 'SINFO'
        dup_detail = details.find do |detail|
          detail.string == values[4].to_s
        end
        if dup_detail
          dup_detail.titles.add(values[0].to_i)
        else
          details << Detail.new(
            values[4].to_s,
            values[2].to_i,
            values[3].to_i,
            Set[values[0].to_i]
          )
        end
      end
    end
    if details.size.zero?
      Logger.error('No disk information found', delayed: true)
      Logger.error(disk_info_string, delayed: true)
    end
    details
  end
  # rubocop:enable AbcSize, CyclomaticComplexity, MethodLength
end
