# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadDiskProcessComponent, type: :component do
  before { render_inline(described_class.new) }

  it 'renders something useful' do
    expect(rendered_content).to include('No disks found - insert disk to continue')
  end
end
