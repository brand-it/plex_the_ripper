# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  ejected        :boolean          default(TRUE), not null
#  name           :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :disk do # rubocop:disable Lint/EmptyBlock
  end
end
