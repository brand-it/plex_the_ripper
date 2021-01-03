# frozen_string_literal: true

RSpec.shared_examples 'HasProgress' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:model) { build_stubbed model_class }

  describe 'associations' do
    it { is_expected.to have_many(:mkv_progresses) }
  end
end
