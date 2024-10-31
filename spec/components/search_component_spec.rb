# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchComponent, type: :component do
  context 'with defaults' do
    before { render_inline(described_class.new) }

    it 'renders something useful' do
      expect(rendered_content).to include('Search for TV or Movie')
    end
  end

  describe '#form_data' do
    context 'when submit_on_key_up is default' do
      subject(:form_data) { described_class.new.form_data }

      it {
        expect(form_data).to eq({
                                  turbo_frame: 'videos',
                                  turbo_action: 'replace',
                                  controller: 'submit-on-keyup'
                                })
      }
    end

    context 'when submit_on_key_up is true' do
      subject(:form_data) { described_class.new(submit_on_key_up: true).form_data }

      it {
        expect(form_data).to eq({
                                  turbo_frame: 'videos',
                                  turbo_action: 'replace',
                                  controller: 'submit-on-keyup'
                                })
      }
    end

    context 'when submit_on_key_up is false' do
      subject(:form_data) { described_class.new(submit_on_key_up: false).form_data }

      it {
        expect(form_data).to eq({
                                  turbo_frame: 'videos',
                                  turbo_action: 'replace'
                                })
      }
    end
  end

  describe '#input_html' do
    context 'when submit_on_key_up is default' do
      subject(:input_html) { described_class.new.input_html }

      it {
        expect(input_html).to eq(
          {
            data: {
              action: 'keyup->submit-on-keyup#submitWithDebounce',
              submit_on_keyup_target: :input
            }
          }
        )
      }
    end

    context 'when submit_on_key_up is true' do
      subject(:input_html) { described_class.new(submit_on_key_up: true).input_html }

      it {
        expect(input_html).to eq(
          {
            data: {
              action: 'keyup->submit-on-keyup#submitWithDebounce',
              submit_on_keyup_target: :input
            }
          }
        )
      }
    end

    context 'when submit_on_key_up is false' do
      subject(:input_html) { described_class.new(submit_on_key_up: false).input_html }

      it {
        expect(input_html).to eq({})
      }
    end
  end
end
