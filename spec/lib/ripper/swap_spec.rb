# frozen_string_literal: true

describe Swap do
  let(:tv_show) do
    VideosLoader.perform
    Config.configuration.videos.tv_shows.first
  end
  let(:season) { tv_show.seasons.first }
  let(:episode) { season.episodes.first }

  describe '.perform' do
    before do
      allow_any_instance_of(Swap).to receive(:find_tv_show).and_return(tv_show)
      allow_any_instance_of(Swap).to receive(:find_season).and_return(season)
      allow_any_instance_of(Swap).to receive(:episode).and_return(episode)
      allow(Shell.prompt).to(
        receive(:yes?).with('Are you sure you want to swap those two files?').and_return(false)
      )
    end
    subject(:perform) { Swap.perform }
    it { expect { perform }.to_not raise_exception }
  end
end
