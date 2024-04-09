# frozen_string_literal: true

# == Schema Information
#
# Table name: progresses
#
#  id                :integer          not null, primary key
#  attempts          :integer          default(0), not null
#  completed_at      :datetime
#  descriptive       :integer          default("download_ftp"), not null
#  failed_at         :datetime
#  key               :string
#  message           :text
#  percentage        :float
#  progressable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  progressable_id   :integer
#
# Indexes
#
#  index_progresses_on_progressable_type_and_progressable_id  (progressable_type,progressable_id)
#
class Progress < ApplicationRecord
  belongs_to :progressable, polymorphic: true

  enum descriptive: { download_ftp: 0, create_mkv: 1 }

  validates :descriptive, presence: true

  def self.generate_key(value)
    value = value.sort.join if value.is_a?(Array)
    return if value.blank?

    ActiveSupport::Digest.hexdigest(value)
  end

  def completed?
    completed_at.present?
  end

  def failed?
    failed_at.present?
  end

  def complete
    assign_attributes(completed_at: Time.current, failed_at: nil, percentage: 100, attempts: attempts + 1)
  end

  def fail(message = nil)
    assign_attributes(completed_at: nil, failed_at: Time.current, message:, attempts: attempts + 1)
  end
end
