# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RenameMkvService do
  let(:movie) { build_stubbed(:movie) }
  let(:result) { OpenStruct.new(dir: movie.tmp_plex_path, mkv_path: movie.tmp_plex_path.dirname.join('something_random.mkv')) }

  before { create :config_plex }

  describe '#call' do
    subject(:call) { described_class.new(video: movie, result: result).call }

    before do
      FileUtils.mkdir_p(result.dir)
      FileUtils.touch(result.mkv_path)
    end

    after do
      FileUtils.remove_entry_secure(result.dir)
      FileUtils.remove_entry_secure(call)
    end

    it 'renames the mkv file and places it in a folder' do # rubocop:disable RSpec/MultipleExpectations
      expect(call).to eq dir.join(movie.plex_path)
      expect(File.exist?(dir.join(movie.plex_path))).to be true
      expect(File.exist?(result.mkv_path)).to be false
    end
  end
end
