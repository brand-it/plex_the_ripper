# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadDiskWorker, type: :worker do
  subject(:worker) { described_class.new(job:) }

  let(:job) { build_stubbed(:job) }
  let(:stdout_str) do
    "/dev/disk3s1s1 on / (apfs, sealed, local, read-only, journaled)\ndevfs on /dev (devfs, local, nobrowse)\n/dev/disk3s6 on /System/Volumes/VM (apfs, local, noexec, journaled, noatime, nobrowse)\n/dev/disk3s2 on " \
      "/System/Volumes/Preboot (apfs, local, journaled, nobrowse)\n/dev/disk3s4 on /System/Volumes/Update (apfs, local, journaled, nobrowse)\n/dev/disk1s2 on /System/Volumes/xarts (apfs, local, noexec, journaled, noatime, nobrowse)" \
      "\n/dev/disk1s1 on /System/Volumes/iSCPreboot (apfs, local, journaled, nobrowse)\n/dev/disk1s3 on /System/Volumes/Hardware (apfs, local, journaled, nobrowse)\n/dev/disk3s5 on /System/Volumes/Data (apfs, local, journaled, " \
      "nobrowse, protect, root data)\nmap auto_home on /System/Volumes/Data/home (autofs, automounted, nobrowse)\n/dev/disk5s1 on /Library/Developer/CoreSimulator/Volumes/iOS_21E213 (apfs, local, nodev, nosuid, read-only, " \
      "journaled, noowners, noatime, nobrowse)\n/dev/disk8s1 on /Library/Developer/CoreSimulator/Volumes/iOS_21C62 (apfs, local, nodev, nosuid, read-only, journaled, noowners, noatime, nobrowse)\n"
  end

  let(:process_status) { instance_double(Process::Status) }

  before do
    allow(Open3).to receive(:capture3).with('mount').and_return([stdout_str, '', instance_double(Process::Status)])
    allow(Open3).to receive(:capture3).with('ps aux | grep makemkvcon | grep -v grep').and_return(['', '', instance_double(Process::Status)])
  end

  describe '#perform' do
    subject(:perform) { worker.perform }

    it { expect { perform }.not_to raise_error }

    it { expect { perform }.to change(Disk, :count).by(1) }
  end
end
