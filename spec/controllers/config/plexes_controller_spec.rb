require 'rails_helper'

RSpec.describe Config::PlexesController, type: :controller do
  describe 'GET directories' do
    subject(:get_folders) { get :directories, format: :json }
    let(:params) { {} }
    let(:expected_directories) do
      dir_path = params.fetch(:directory, Dir.home)
      entities = Dir.entries(dir_path)
      entities.map { |e| File.join(dir_path, e) }.select { |e| File.directory?(e) }
    end

    it 'Responds with the default home path' do
      expect(JSON.parse(get_folders.body)).to eq expected_directories
    end

    context 'when providing a dir params' do
      let(:params) { { directory: Rails.root } }

      it 'responds with all the files in rails root' do
        expect(JSON.parse(get_folders.body)).to eq expected_directories
      end
    end
  end
end
