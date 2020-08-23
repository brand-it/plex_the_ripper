# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tv, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:original_name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:seasons) }
  end
end
