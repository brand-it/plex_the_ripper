# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::PlexesController do
  before do
    create(:config_make_mkv)
    allow(Ftp::ListDir).to receive(:search).and_return(Ftp::ListDir::Result.new(nil, [], true))
  end

  let(:config) { create(:config_plex) }

  describe 'GET directories' do
    subject(:get_folders) { get :directories, params:, format: :json }

    let(:params) { { id: config.id } }

    context 'when not using ftp' do
      let(:params) { super().merge(directory: Rails.root) }
      let(:expected_directories) do
        { 'dirs' => [], 'message' => nil, 'success' => true }
      end

      it 'responds with all the files in rails root' do
        expect(JSON.parse(get_folders.body)).to eq expected_directories
      end
    end

    # context 'when using ftp' do
    # end
  end
end
