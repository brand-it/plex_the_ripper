# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  config_type :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  config_id   :bigint
#
# Indexes
#
#  index_users_on_config_type_and_config_id  (config_type,config_id)
#
class User < ApplicationRecord
  belongs_to :config, polymorphic: true, optional: true

  validates :name, presence: true
end
