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
  end
end
