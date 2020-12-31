# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Config::MakeMkv, type: :model do
  describe 'validations' do
    let(:config_make_mkv) { build_stubbed(:config_make_mkv) }

    describe '#mkvemkvcon_path_present' do
      it 'does not raise validation error when mkvemkvcon_path is present' do
        config_make_mkv.settings = { makemkvcon_path: '/failure' }
        config_make_mkv.valid?
        expect(config_make_mkv.errors['settings']).to eq ['makemkvcon path /failure is not an executable']
      end

      it 'does raise validation error when mkvemkvcon_path is present' do
        config_make_mkv.settings = { makemkvcon_path: '' }
        config_make_mkv.valid?
        expect(config_make_mkv.errors['settings']).to eq ['makemkvcon path is required']
      end
    end

    describe '#makemkvcon_path_executable' do
      it 'does not raise validation error if makemkvcon_path blank' do
        config_make_mkv.settings = { makemkvcon_path: '' }
        config_make_mkv.valid?
        expect(config_make_mkv.errors['settings']).to eq ['makemkvcon path is required']
      end

      it 'raise validation error if makemkvcon_path is not a executable' do
        config_make_mkv.settings = { makemkvcon_path: '/failure' }
        config_make_mkv.valid?
        expect(config_make_mkv.errors['settings']).to eq ['makemkvcon path /failure is not an executable']
      end

      it 'does not raise validation error if makemkvcon_path is a executable' do
        allow(File).to receive(:executable?).and_return(true)
        config_make_mkv.settings = { makemkvcon_path: '/failure' }
        config_make_mkv.valid?
        expect(config_make_mkv.errors['settings']).to eq []
      end
    end
  end
end
