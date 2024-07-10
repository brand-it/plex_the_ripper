# frozen_string_literal: true

RSpec.shared_examples 'IsVideo' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:model) { build_stubbed(model_class) }

  describe '#release_or_air_date', :freeze do
    subject(:release_or_air_date) { video.release_or_air_date }

    let(:expected_date) { Time.zone.today }
    let(:unexpected_date) { 2.days.ago }

    context 'when release_date is present' do
      let(:video) { build_stubbed(model_class, release_date: expected_date, episode_first_air_date: nil) }

      it { is_expected.to eq expected_date }
    end

    context 'when episode_first_air_date is present' do
      let(:video) { build_stubbed(model_class, release_date: nil, episode_first_air_date: expected_date) }

      it { is_expected.to eq expected_date }
    end

    context 'when both release_date & episode_first_air_date is present' do
      let(:video) do
        build_stubbed(
          model_class,
          release_date: expected_date,
          episode_first_air_date: unexpected_date
        )
      end

      it { is_expected.to eq expected_date }
    end
  end
end
