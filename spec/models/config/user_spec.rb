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
require 'rails_helper'

RSpec.describe Config::User, type: :model do
  let(:config) { build_stubbed :config_user }

  describe '#default_settings' do
    let(:expected_settings) do
      Config::SettingSerializer.new(
        dark_mode: true,
        the_movie_db_api_key: nil,
        the_movie_db_session_id: nil
      )
    end

    it 'has defaults' do
      expect(config.settings).to eq expected_settings
    end
  end
end
