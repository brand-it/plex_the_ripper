# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiskListener do
  subject(:listener) { described_class.new(**args) }

  let(:args) { {} }

  include ActionView::Helpers::UrlHelper
  delegate :job_url, to: 'Rails.application.routes.url_helpers'

  describe '#disk_loaded' do
    subject(:disk_loaded) { listener.disk_loaded(disk) }

    before do
      allow(listener).to receive(:cable_ready).and_return(cable_ready)
      allow(channel).to receive(:reload)
      allow(channel).to receive(:redirect_to)
      allow(cable_ready).to receive(:broadcast)
    end

    let(:cable_ready) { instance_double(CableReady::Channels, '[]': channel) }
    let(:channel) { CableReady::Channel.new('broadcast') }

    context 'when disk has auto load off' do
      let(:disk) { create(:disk) }

      it 'broadcast a page reload' do
        expect(disk_loaded).to be_nil
        expect(channel).to have_received(:reload)
        expect(cable_ready).to have_received(:broadcast)
      end
    end

    context 'when the disk loaded is not a movie & auto start is true' do
      let(:disk) { create(:disk, video:) }
      let(:video) { create(:tv, auto_start: true) }

      it 'broadcast a page reload' do
        expect(disk_loaded).to be_nil
        expect(channel).to have_received(:reload)
        expect(cable_ready).to have_received(:broadcast)
      end
    end

    context 'when disk has auto start set to true' do
      let(:disk) { create(:disk, video:, disk_titles:) }
      let(:video) { create(:movie, movie_runtime: 20, auto_start: true) }
      let(:disk_titles) { create_list(:disk_title, 2, duration: 20) }

      it 'broadcast a redirect to the new job' do
        expect(disk_loaded).to be_nil
        expect(channel).not_to have_received(:reload)
        expect(channel).to have_received(:redirect_to).with(url: job_url(Job.newest.first))
      end
    end
  end
end
