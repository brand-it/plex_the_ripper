# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/users/show', type: :view do
  let(:config_user) { build_stubbed(:config_user) }
  before { assign(:config_user, config_user) }

  it 'renders attributes in <p>' do
    render
  end
end
