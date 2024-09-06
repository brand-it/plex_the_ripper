# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadDiskProcessComponent, type: :component do
  let(:component) { described_class.new }

  before { render_inline(component) }

  it 'renders something useful' do
    expect(rendered_content).to include('<div id="load-disk-process-component" class="hidden"></div>')
  end

  context 'when hidden is false' do
    let(:component) do
      allow(described_class).to receive(:show?).and_return(true)
      described_class.new
    end

    it 'show the component' do
      expect(rendered_content).to include('No disks found - insert disk to continue')
    end
  end
end
