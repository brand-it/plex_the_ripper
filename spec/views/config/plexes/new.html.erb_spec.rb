# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/new', type: :view do
  before do
    assign(:config_plex, Config::Plex.new)
  end

  it 'renders new config_plex form' do
    render

    assert_select 'form[action=?][method=?]', config_plex_path, 'post' do
    end
  end
end
