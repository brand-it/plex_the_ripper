# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :freeze) do
    Timecop.freeze(self.class.metadata[:freeze] || Time.current)
  end

  config.after(:each, :freeze) do
    Timecop.return
  end
end
