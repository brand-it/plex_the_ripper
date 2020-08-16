# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/show', type: :view do
  before do
    @config_plex = assign(:config_plex, Config::Plex.create!)
  end

  it 'renders attributes in <p>' do
    render
  end
end
