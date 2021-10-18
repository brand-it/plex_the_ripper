# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadProgressListener do
  subject(:listener) { described_class.new(**args) }

  describe '#call' do
    subject(:call) { listener.call(chunk_size: 10) }

    let(:args) do
      {
        completed: 0,
        title: 'title',
        message: 'message',
        file_size: 12
      }
    end

    it { expect { call }.not_to raise_error }

    it 'changes the completed size based on the chunk size' do
      call

      expect(listener.completed).to eq 10
    end
  end
end
