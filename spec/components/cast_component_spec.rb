# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CastComponent, type: :component do
  before do
    create(:config_the_movie_db)
    render_inline(described_class.new(video:))
  end

  describe 'render' do
    context 'when video is a movie', vcr: { record: :once, cassette_name: "#{described_class}/render_movie" } do
      let(:video) { create(:movie, title: 'Frosty the Snowman', the_movie_db_id: 13_675) }

      it 'renders something useful' do
        expect(rendered_content).to include('Karen (uncredited)')
      end
    end

    context 'when video is a tv show', vcr: { record: :once, cassette_name: "#{described_class}/render_tv" } do
      let(:video) { create(:tv, title: 'Firefly', the_movie_db_id: 72_893) }

      it 'renders something useful' do
        expect(rendered_content).to include('Aslı Eğilmez')
      end
    end

    context 'when the movie has not cast info' do
      let(:video) { create(:movie, title: 'Frosty the Snowman', the_movie_db_id: nil) }

      it 'renders nothing' do
        expect(rendered_content).to eq ''
      end
    end
  end
end
