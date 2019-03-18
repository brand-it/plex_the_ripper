# frozen_string_literal: true

describe AskForVideoDetails do
  describe '.perform' do
    before do
      allow(Config.configuration.the_movie_db_config).to receive(:valid_api_key?).and_return(false)
      allow(Shell).to(
        receive(:ask).with('What is the Name of this movie:', type: String).and_return('Star Trek')
      )
      allow(Shell.prompt).to(
        receive(:select).with('Please select a video type', %i[movie tv]).and_return(:movie)
      )
    end
    subject(:perform) { AskForVideoDetails.perform }
    it { expect { perform }.to_not raise_exception }
  end
end
