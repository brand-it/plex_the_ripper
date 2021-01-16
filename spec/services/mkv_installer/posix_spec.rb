# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MkvInstaller::Posix do
  it 'does not raise and error' do
    expect { described_class.new }.not_to raise_error
  end
end
