# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/edit', type: :view do
  before do
    @config_plex = assign(:config_plex, Config::Plex.create!)
  end

  it 'renders the edit config_plex form' do
    render

    assert_select 'form[action=?][method=?]', config_plex_path(@config_plex), 'post' do
    end
  end
end
