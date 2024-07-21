# frozen_string_literal: true

class CheckForUpgradeService < ApplicationService
  Result = Struct.new(:upgrade, :version)
  REPO = 'brand-it/plex_the_ripper'
  API_URL = "https://api.github.com/repos/#{REPO}/releases/latest".freeze

  def call
    Result.new(newer_version?, latest_version)
  end

  def newer_version?
    return false if latest_version.blank?

    release_version = Gem::Version.new(latest_version)
    current_version = Gem::Version.new(PlexRipper::VERSION)
    release_version > current_version
  end

  def latest_version
    @latest_version ||= release_info['tag_name']&.gsub('v', '')
  end

  def release_info
    Rails.cache.fetch(PlexRipper::VERSION, namespace: 'new_version_available', expires_in: 1.hour) do
      uri = URI(API_URL)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end
  rescue StandardError
    {}
  end
end
