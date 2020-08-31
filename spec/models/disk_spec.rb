# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disk, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:episodes) }
    it { is_expected.to have_many(:disk_titles) }
  end
end
