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
#  name          :string           not null
#  started_at    :datetime
#  status        :string           default("enqueued"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :job do
    name { 'UploadWorker' }
  end
end
