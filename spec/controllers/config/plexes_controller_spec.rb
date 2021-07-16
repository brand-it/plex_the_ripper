# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::PlexesController, type: :controller do
  before { create :config_make_mkv }

  let(:config) { create :config_plex }

  describe 'GET directories' do
    subject(:get_folders) { get :directories, params: params, format: :json }

    let(:params) { { id: config.id } }

    context 'when not using ftp' do
      let(:params) { super().merge(directory: Rails.root) }
      let(:expected_directories) do
        dir_path = params.fetch(:directory, Dir.home)
        entities = Dir.entries(dir_path)
        entities.map { |e| File.join(dir_path, e) }.select { |e| File.directory?(e) }
      end

      it 'responds with all the files in rails root' do
        expect(JSON.parse(get_folders.body)).to eq expected_directories
      end
    end

    # context 'when using ftp' do
    # end
  end
end
