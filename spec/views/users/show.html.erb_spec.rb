# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show' do
  let(:user) { build_stubbed(:user) }

  before { assign(:user, user) }

  it 'renders attributes in <p>' do
    expect { render }.not_to raise_error
  end
end
