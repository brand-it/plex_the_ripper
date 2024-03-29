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

RSpec.describe Config::TheMovieDb do
  let(:config) { build_stubbed(:config_the_movie_db, settings: { api_key: 12_345 }) }

  describe '#default_settings' do
    let(:expected_settings) { Config::Serializer.new(api_key: 12_345) }

    it 'has defaults' do
      expect(config.settings).to eq expected_settings
    end
  end
end
