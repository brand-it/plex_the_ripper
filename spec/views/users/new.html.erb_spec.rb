# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/new' do
  let(:user) { build(:user) }

  before { assign(:user, user) }

  it 'renders new user form' do
    expect { render }.not_to raise_error
  end
end
