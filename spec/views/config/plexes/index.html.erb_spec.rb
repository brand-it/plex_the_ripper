# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/index' do
  before do
    assign(:config_plexes, [
             build_stubbed(:config_plex),
             build_stubbed(:config_plex)
           ])
  end

  it 'renders a list of config/plexes' do
    expect { render }.not_to raise_error
  end
end
