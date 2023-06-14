# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/edit' do
  let(:user) { create(:user) }

  before { assign(:user, user) }

  it 'renders the edit user form' do
    render

    assert_select 'form[action=?][method=?]', user_path(user), 'post' do # rubocop:disable Lint/EmptyBlock
    end
  end
end
