# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  config_type :string
#  name        :string           not null
#  time_zone   :string(255)      default("Pacific Time (US & Canada)"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  config_id   :bigint
#
# Indexes
#
#  index_users_on_config_type_and_config_id  (config_type,config_id)
#
require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
