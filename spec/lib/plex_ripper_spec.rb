# frozen_string_literal: true
# # frozen_string_literal: true
# ugh this is going to suck to test... it is designed to loop forever.... FOREVER
# how do you test a loop that never ends. It like a boat ride that never ends...
# Thanks Disney land and small world.

# describe Plex::Ripper do
#   let(:tv_show) do
#     VideosLoader.perform
#     Config.configuration.videos.tv_shows.first
#   end
#   let(:season) { tv_show.seasons.first }
#   let(:episode) { season.episodes.first }

#   describe '.swapper' do
#     before do
#       allow_any_instance_of(Swap).to receive(:find_tv_show).and_return(tv_show)
#       allow_any_instance_of(Swap).to receive(:find_season).and_return(season)
#       allow_any_instance_of(Swap).to receive(:episode).and_return(episode)
#       allow(Shell.prompt).to(
#         receive(:yes?).with('Are you sure you want to swap those two files?').and_return(false)
#       )
#     end
#     subject(:swapper) { Plex::Ripper.swapper }
#     it { expect { swapper }.to_not raise_exception }
#   end
# end
