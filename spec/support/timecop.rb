# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :freeze) do
    date_time = self.class.metadata[:freeze]
    Timecop.freeze(date_time.is_a?(TrueClass) ? Time.current : date_time)
  end

  config.after(:each, :freeze) do
    Timecop.return
  end
end
