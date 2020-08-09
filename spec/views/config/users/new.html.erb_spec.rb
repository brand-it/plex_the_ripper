# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/users/new', type: :view do
  before { assign(:config_user, build_stubbed(:config_user)) }

  it 'renders new config_user form' do
    render

    # assert_select 'form[action=?][method=?]', config_users_path, 'post' do
    # end
  end
end
