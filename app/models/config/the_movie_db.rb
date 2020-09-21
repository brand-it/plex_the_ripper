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
    settings_defaults(api_key: nil)

    def settings_invalid?
      settings&.api_key.blank?
    end
  end
end
