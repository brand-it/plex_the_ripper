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
  class Slack < Config
    setting do |s|
      s.attribute :webhook_url
      s.attribute :channel
    end

    validates :settings_webhook_url, presence: true
    validates :settings_channel, presence: true, format: { with: /\A#/, message: 'must start with a # symbol' }
  end
end
