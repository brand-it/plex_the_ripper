# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/users/index', type: :view do
  before { assign(:config_users, build_stubbed_list(:config_user, 2)) }

  it 'renders a list of config/users' do
    render
  end
end
