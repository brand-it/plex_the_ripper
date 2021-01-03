# frozen_string_literal: true

RSpec.shared_examples 'AsVideo' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:video_one) { create model_class }
  let(:video_two) { create model_class }
  describe 'validations' do
    
  end
  describe '.find_video' do
    subject(:find_video) { model_class.find_video(id) }

    before do
      video_one
      video_two
    end

    context 'find by the the_movie_db_id' do
      let(:id) { video_one.the_movie_db_id }

      it 'finds a video' do
        expect(find_video).to eq video_one
      end
    end

    context 'find by the id' do
      let(:id) { video_one.id }

      it 'finds the video' do
        expect(find_video).to eq video_one
      end
    end

    context 'when no record can be found' do
      let(:id) { 0 }

      it 'finds the video' do
        expect { find_video }.not_to raise_error
      end
    end
  end
end
