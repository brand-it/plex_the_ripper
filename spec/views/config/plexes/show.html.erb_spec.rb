# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/show' do
  before do
    @config_plex = assign(:config_plex, build_stubbed(:config_plex))
  end

  it 'renders attributes in <p>' do
    expect { render }.not_to raise_error
  end
end
