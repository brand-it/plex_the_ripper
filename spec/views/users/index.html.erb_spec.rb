# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  let(:users) { build_stubbed_list(:user, 2) }

  before { assign(:users, users) }

  it 'renders a list of users' do
    render
  end
end
