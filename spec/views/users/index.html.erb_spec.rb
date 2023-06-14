# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index' do
  let(:users) { build_stubbed_list(:user, 2) }

  before { assign(:users, users) }

  it 'renders a list of users' do
    expect { render }.not_to raise_error
  end
end
