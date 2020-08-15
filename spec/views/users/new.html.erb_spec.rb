# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/new', type: :view do
  let(:user) { build(:user) }

  before { assign(:user, user) }

  it 'renders new user form' do
    render

    assert_select 'form[action=?][method=?]', users_path, 'post' do
    end
  end
end
