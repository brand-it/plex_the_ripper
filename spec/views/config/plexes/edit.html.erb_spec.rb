# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/plexes/edit' do
  let(:config_plex) { create(:config_plex) }

  before { assign(:config_plex, config_plex) }

  it 'renders the edit config_plex form' do
    render

    assert_select 'form[action=?][method=?]', config_plex_path, 'post' do # rubocop:disable Lint/EmptyBlock
    end
  end
end
