# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/the_movie_dbs/new' do
  before { assign(:config_the_movie_db, build_stubbed(:config_the_movie_db)) }

  it 'renders new the_movie_db form' do
    expect { render }.not_to raise_error

    # assert_select 'form[action=?][method=?]', config_users_path, 'post' do
    # end
  end
end
