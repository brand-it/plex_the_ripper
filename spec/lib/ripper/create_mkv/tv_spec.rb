# frozen_string_literal: true

describe CreateMKV::TV do
  before do
    Config.configuration.type = :tv
    Config.configuration.video_name = name
    Config.configuration.episode = 1
    Config.configuration.disc_number = 1
    FileUtils.mkdir_p(AskForFilePathBuilder.path)
  end
  let(:name) { Faker::FunnyName.name }

  let(:mkv_titles) do
    ['Star Trek Season 1- Disc 7_t00.mkv', 'Star Trek Season 1- Disc 7_t02.mkv']
  end

  let(:create_mkv_files) do
    mkv_titles.each do |mkv|
      FileUtils.touch("#{AskForFilePathBuilder.path}/#{mkv}")
    end
  end

  after do
    FileUtils.remove_dir(
      File.join(
        [
          Config.configuration.media_directory_path,
          Config.configuration.tv_shows_directory_name,
          name
        ]
      )
    )
  end

  describe '.perform' do
    subject(:perform) { CreateMKV::TV.perform }
    it { expect { perform }.to_not raise_exception }
    context 'make mkv creates 2 files' do
      before do
        allow_any_instance_of(CreateMKV::TV).to receive(:create_mkv).and_return(create_mkv_files)
        perform
      end
      it { expect(perform.mkv_files(reload: true).size).to eq mkv_titles.size }
      it { expect(perform.mkv_files(reload: true).first).to eq "#{name} - s01e01.mkv" }
    end
  end
end
