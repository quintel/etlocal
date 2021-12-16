# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::KeyMap do
  describe '.identity' do
    it 'returns a proc which returns its parameter' do
      expect(described_class.identity.call(:foo)).to eq(:foo)
    end
  end

  describe '.from_hash' do
    let(:key_map) do
      described_class.from_hash(
        'foo' => 'bar',
        'baz' => 'qux'
      )
    end

    it 'returns a mapped key when it exists' do
      expect(key_map.call('baz')).to eq('qux')
    end

    it 'throws KeyError when the key does not exist' do
      expect { key_map.call('quux') }.to raise_error(KeyError)
    end
  end
end
