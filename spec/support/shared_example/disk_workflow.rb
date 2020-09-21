# frozen_string_literal: true

RSpec.shared_examples 'DiskWorkflow' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:model) { create model_class }
  # A
  describe 'associations' do
    it { is_expected.to belong_to(:disk).optional }
  end
  # W

  describe 'workflow' do
    subject(:workflow) { model.current_state }

    context 'when initialize' do
      it { is_expected.to eq :new }
    end

    it 'handles transition to success' do # rubocop:disable RSpec/MultipleExpectations
      expect { model.select! }.to change { model.current_state.name }.from(:new).to(:selected)
      expect { model.rip! }.to change { model.current_state.name }.from(:selected).to(:ripping)
      expect { model.complete! }.to change { model.current_state.name }.from(:ripping).to(:completed)
    end

    it 'handles transition to canceled' do # rubocop:disable RSpec/MultipleExpectations
      expect { model.select! }.to change { model.current_state.name }.from(:new).to(:selected)
      expect { model.cancel! }.to change { model.current_state.name }.from(:selected).to(:new)
    end

    it 'handles transition canceled from failed' do # rubocop:disable RSpec/MultipleExpectations
      expect { model.select! }.to change { model.current_state.name }.from(:new).to(:selected)
      expect { model.rip! }.to change { model.current_state.name }.from(:selected).to(:ripping)
      expect { model.fail! }.to change { model.current_state.name }.from(:ripping).to(:failed)
      expect { model.cancel! }.to change { model.current_state.name }.from(:failed).to(:new)
    end

    it 'handles transition to failure' do # rubocop:disable RSpec/MultipleExpectations
      expect { model.select! }.to change { model.current_state.name }.from(:new).to(:selected)
      expect { model.rip! }.to change { model.current_state.name }.from(:selected).to(:ripping)
      expect { model.fail! }.to change { model.current_state.name }.from(:ripping).to(:failed)
    end
  end
end
