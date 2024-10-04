# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Config
  class TheMovieDb < Config
    setting do |s|
      s.attribute :api_key
    end

    validates :settings_api_key, presence: true
    validate :api_key_valid

    def api_key_valid
      return if Rails.env.test? # lazy did not want to test

      ::TheMovieDb::Search::Movie.new(
        api_key: settings_api_key,
        query: 'Star Wars',
        use_cache: false
      ).results
    rescue ::TheMovieDb::Error => e
      errors.add(:settings_api_key, e.body&.dig('status_message'))
    end
  end
end
