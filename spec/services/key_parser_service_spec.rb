# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeyParserService do
  let(:movie_path) { '/Media/Movies' }
  let(:tv_path) { '/Media/TV Shows' }

  YAML.load_file('spec/fixtures/video_blob_keys.yml')[:video_blob].each do |blob|
    describe '#call' do
      subject(:call) { described_class.new(blob[:key], movie_path:, tv_path:).call }

      context blob[:key] do
        it 'validates data attributes' do
          described_class::BlobData.members.each do |member|
            expect(call.send(member)).to(eq(blob[member]),
                                         "Expected #{member} to eq #{blob[member]} but got #{call.send(member)}")
          end
          expect(call.tv?).to eq(blob[:type] == 'Tv')
          expect(call.movie?).to eq(blob[:type] == 'Movie')
        end
      end
    end
  end
end
