# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Season, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:season_number) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:episodes) }
    it { is_expected.to belong_to(:tv) }
  end
end
