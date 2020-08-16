require 'rails_helper'

RSpec.describe "config/plexes/new", type: :view do
  before(:each) do
    assign(:config_plex, Config::Plex.new())
  end

  it "renders new config_plex form" do
    render

    assert_select "form[action=?][method=?]", config_plexes_path, "post" do
    end
  end
end
