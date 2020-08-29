# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Episode, type: :model do
  include_context 'DiskWorkflow'
  describe 'associations' do
    it { is_expected.to belong_to(:season) }
    it { is_expected.to belong_to(:disk).optional(true) }
    it { is_expected.to belong_to(:disk_title).optional(true) }
  end
end
