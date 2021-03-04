# frozen_string_literal: true

RSpec.shared_examples 'IsVideo' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:model) { build_stubbed model_class }

  describe '#release_or_air_date', :freeze do
    subject(:release_or_air_date) { video.release_or_air_date }

    let(:expected_date) { Time.zone.today }
    let(:unexpected_date) { 2.days.ago }

    context 'when release_date is present' do
      let(:video) { build_stubbed model_class, release_date: expected_date, episode_first_air_date: nil }

      it { is_expected.to eq expected_date }
    end

    context 'when episode_first_air_date is present' do
      let(:video) { build_stubbed model_class, release_date: nil, episode_first_air_date: expected_date }

      it { is_expected.to eq expected_date }
    end

    context 'when both release_date & episode_first_air_date is present' do
      let(:video) do
        build_stubbed\
          model_class,
          release_date: expected_date,
          episode_first_air_date: unexpected_date
      end

      it { is_expected.to eq expected_date }
    end
  end

  describe '.find_video' do
    subject(:find_video) { described_class.find_video(id) }

    let!(:video_one) { create model_class, :with_movie_db_id }
    let!(:video_two) { create model_class }

    context 'when find by the the_movie_db_id' do
      let(:id) { video_one.the_movie_db_id }

      it 'finds a video' do
        expect(find_video).to eq video_one
      end

      it 'does not return second video' do
        expect(find_video).not_to eq video_two
      end
    end

    context 'when id is null' do
      let(:id) { nil }

      it 'finds the video' do
        expect { find_video }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'when find by the id' do
      let(:id) { video_one.id }

      it 'finds the video' do
        expect(find_video).to eq video_one
      end

      it 'does not return second video' do
        expect(find_video).not_to eq video_two
      end
    end

    context 'when no record can be found' do
      let(:id) { 0 }

      it 'finds the video' do
        expect { find_video }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
