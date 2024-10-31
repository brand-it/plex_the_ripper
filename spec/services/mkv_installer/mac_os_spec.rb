# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MkvInstaller::MacOs do
  let(:mac_os) { described_class.new }

  describe '.call', :vcr do
    subject(:call) { mac_os.call }

    before do
      allow(mac_os).to receive_messages(system!: true,
                                        dmg_file: instance_double(File,
                                                                  path: 'dignissimos-voluptate/id.tiff'))
      allow(FileUtils).to receive(:cp_r)
      allow(FileUtils).to receive(:rm_rf)
      allow(Open3).to receive(:capture3).with('mount').and_return(
        ['', '', instance_double(Process::Status)]
      )
    end

    it 'calls all the right things' do
      call
      expect(FileUtils).to have_received(:cp_r).with '/Volumes/makemkv_v1.17.7/MakeMKV.app',
                                                     '/Applications/MakeMKV.app'
      expect(FileUtils).to have_received(:rm_rf)
      expect(mac_os).to have_received(:system!).with('hdiutil attach dignissimos-voluptate/id.tiff')
    end
  end
end
