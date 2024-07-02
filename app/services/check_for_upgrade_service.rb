# frozen_string_literal: true

class CheckForUpgradeService
  REPO = 'brand-it/plex_the_ripper'
  API_URL = "https://api.github.com/repos/#{REPO}/releases/latest".freeze

  def self.call
    new.call
  end

  def call
    release_info['tag_name'] != PlexRipper::VERSION
  end

  def release_info
    Rails.cache.fetch('new_version_available', expires_in: 24.hours) do
      uri = URI(API_URL)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end
  rescue StandardError
    {}
  end
end
