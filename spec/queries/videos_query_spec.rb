# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideosQuery do
  subject(:query) { described_class.new(**filters) }

  describe '#types_and_ids' do
    context 'when providing more then two types and ids' do
      let(:filters) do
        {
          types_and_ids: [
            { id: 1234, type: 'Movie' },
            { id: 5343, type: 'Movie' },
            { id: 4423, type: 'Tv' }
          ]
        }
      end
      let(:expected_sql) do
        "((videos.type = 'Movie' AND videos.the_movie_db_id = 1234) OR "\
          "(videos.type = 'Movie' AND videos.the_movie_db_id = 5343) OR "\
          "(videos.type = 'Tv' AND videos.the_movie_db_id = 4423)"
      end

      it 'joins them together with or statement' do
        expect(query.to_sql).to include expected_sql
      end
    end
  end
end
