# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { build_stubbed :user }

  before { assign(:user, user) }

  it 'renders attributes in <p>' do
    render
  end
end
