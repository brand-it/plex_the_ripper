# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Movie, type: :model do
  include_context 'DiskWorkflow'
  # V
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:original_title) }
  end
end
