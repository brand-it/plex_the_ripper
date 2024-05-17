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
  pending "add some examples to (or delete) #{__FILE__}"
end
