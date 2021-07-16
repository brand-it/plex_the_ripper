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

RSpec.describe Config::Plex, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:settings_movie_path) }
    it { is_expected.to validate_presence_of(:settings_tv_path) }
  end
end
