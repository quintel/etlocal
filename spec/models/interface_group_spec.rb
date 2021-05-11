# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterfaceGroup do
  describe 'an InterfaceGroup with no explicit type' do
    it 'sets the type to :static' do
      expect(described_class.new.type).to eq(:static)
    end

    it 'may have items' do
      group = described_class.new(items: [InterfaceItem.new])
      group.valid?

      expect(group.errors[:items]).to be_blank
    end

    it 'may not have paths' do
      group = described_class.new(paths: ['a'])
      group.valid?

      expect(group.errors[:paths]).to include('must be blank')
    end
  end

  describe 'an InterfaceGroup with type=:files' do
    let(:group) { described_class.new(type: :files) }

    it 'sets the type to :static' do
      expect(group.type).to eq(:files)
    end

    it 'may have paths' do
      group.paths = ['a']
      group.valid?

      expect(group.errors[:paths]).to be_blank
    end

    it 'may not have items' do
      group.items = [InterfaceItem.new]
      group.valid?

      expect(group.errors[:items]).to include('must be blank')
    end

    context 'with a path "../a.csv"' do
      before { group.paths = ['../a.csv'] }

      it 'is invalid' do
        group.valid?

        expect(group.errors[:paths]).to include(
          'may not include path to a parent directory ("../a.csv")'
        )
      end
    end

    context 'with a path "a/../a.csv"' do
      before { group.paths = ['a/../a.csv'] }

      it 'is invalid' do
        group.valid?

        expect(group.errors[:paths]).to include(
          'may not include path to a parent directory ("a/../a.csv")'
        )
      end
    end
  end
end
