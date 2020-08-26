# frozen_string_literal: true

RSpec.describe DiskInfoService do
  let(:new) { describe_class.new }

  describe '#call' do
    subject(:call) { new.call }

    context 'when titles are found' do
      let(:stubbed_drive) do
      end

      before do
        allow(new).to receive(:info_response).and_return(stubbed_info_response)
        any_instance_of(ListDrivesService)
      end

      it 'returns a list of found titles' do
        expect(call).to eq []
      end
    end
  end
end
