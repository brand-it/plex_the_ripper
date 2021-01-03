# frozen_string_literal: true

RSpec.shared_examples 'DiskWorkflow' do |_parameter|
  let(:model_class) { described_class.model_name.singular.to_sym }
  let(:model) { build_stubbed model_class }

  # A
  describe 'associations' do
    it { is_expected.to have_many(:disk_titles) }
  end

  # W
  describe 'workflow' do
    subject(:workflow) { model.current_state }

    let(:disk_title) { create :disk_title }

    context 'when initialize' do
      it { is_expected.to eq :new }
    end

    context 'when event select!' do
      before { model.workflow_state = nil }

      it { expect { model.select! }.to change { model.current_state.name }.from(:new).to(:selected) }
    end

    context 'when event select_disk_titles!' do
      before { model.workflow_state = 'selected' }

      it 'changes state from selected to ready to rip' do
        expect { model.select_disk_titles!([disk_title]) }.to change {
                                                                model.current_state.name
                                                              }.from(:selected).to(:ready_to_rip)
      end
    end

    context 'when event cancel!' do
      it 'changes state from selected to new' do
        model.workflow_state = 'selected'
        expect { model.cancel! }.to change { model.current_state.name }.from(:selected).to(:new)
      end

      it 'changes state from ready_to_rip to new' do
        model.workflow_state = 'ready_to_rip'
        expect { model.cancel! }.to change { model.current_state.name }.from(:ready_to_rip).to(:new)
      end
    end

    context 'when event rip!' do
      before { model.workflow_state = 'ready_to_rip' }

      it { expect { model.rip! }.to change { model.current_state.name }.from(:ready_to_rip).to(:ripping) }
    end

    context 'when event fail!' do
      before { model.workflow_state = 'ripping' }

      it { expect { model.fail! }.to change { model.current_state.name }.from(:ripping).to(:failed) }
    end

    context 'when event complete!' do
      before { model.workflow_state = 'ripping' }

      it { expect { model.complete! }.to change { model.current_state.name }.from(:ripping).to(:completed) }
    end

    context 'when event retry!' do
      before { model.workflow_state = 'failed' }

      it { expect { model.retry! }.to change { model.current_state.name }.from(:failed).to(:ripping) }
    end
  end
end
