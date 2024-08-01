# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id            :integer          not null, primary key
#  arguments     :text
#  backtrace     :text
#  ended_at      :datetime
#  error_class   :string
#  error_message :string
#  metadata      :text             default({}), not null
#  name          :string           not null
#  started_at    :datetime
#  status        :string           default("enqueued"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe Job do
  let(:job) { build(:job) }

  describe 'scopes' do
    it { is_expected.to have_scope(:active).where(status: described_class::ACTIVE_STATUSES) }
    it { is_expected.to have_scope(:completed).where(status: described_class::COMPLETED_STATUSES) }
    it { is_expected.to have_scope(:sort_by_created_at).order(created_at: :desc) }
    it { is_expected.to have_scope(:hanging).where(status: described_class::HANGING_STATUSES) }
  end

  describe '#completed=' do
    it 'updated completed' do
      job.completed ||= 1
      job.completed = 2
      expect(job.metadata['completed']).to eq(2.0)
    end

    it 'updated with complex' do
      job.completed ||= 1
      job.completed += 2
      expect(job.metadata['completed']).to eq(3.0)
    end
  end
end
