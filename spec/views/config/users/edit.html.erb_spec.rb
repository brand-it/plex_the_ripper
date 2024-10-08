# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'config/the_movie_dbs/edit' do
  let(:config_the_movie_db) { build_stubbed(:config_the_movie_db) }

  before { assign(:config_the_movie_db, config_the_movie_db) }

  it 'renders the edit the_movie_db form' do
    expect { render }.not_to raise_error

    # assert_select "form[action=?][method=?]", the_movie_db_path(@config_user), "post" do
    # end
  end
end
