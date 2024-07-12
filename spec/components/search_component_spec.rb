# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchComponent, type: :component do
  before { render_inline(described_class.new) }

  it 'renders something useful' do
    expect(rendered_content).to include('Search for TV or Movie')
  end
end
