# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/users/edit', type: :view do
  before(:each) do
    @config_user = assign(:config_user, Config::User.create!)
  end

  it 'renders the edit config_user form' do
    render

    assert_select 'form[action=?][method=?]', config_user_path(@config_user), 'post' do
    end
  end
end
