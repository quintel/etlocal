# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::ColumnAggregatedMap do
  let(:original) do
    DatasetSource::Map.new(
      'a' => { 'x' => 1, 'y' => 2 },
      'b' => { 'x' => 3, 'y' => 4 },
      'c' => { 'x' => 5, 'y' => 6 }
    )
  end

  let(:aggregate) do
    described_class.new(original, 'alias' => %w[x y])
  end

  describe '#column?' do
    it 'returns true when given a matching alias' do
      expect(aggregate.column?('alias')).to be(true)
    end

    it 'returns true when given a real column' do
      expect(aggregate.column?('x')).to be(true)
    end

    it 'returns false when when no alias or column matches' do
      expect(aggregate.column?('z')).to be(false)
    end
  end

  describe '#get!' do
    it 'returns a summed value when given an alias' do
      expect(aggregate.get!('a', 'alias')).to eq(3)
    end

    it 'returns an original value when given a row' do
      expect(aggregate.get!('b', 'y')).to eq(4)
    end

    it 'raises a KeyError when no column or alias matches' do
      expect { aggregate.get!('a', 'z') }.to raise_error(KeyError, /key not found: "z"/)
    end

    it 'raises a KeyError given an alias and no row matches' do
      expect { aggregate.get!('d', 'alias') }.to raise_error(KeyError, /key not found: "d"/)
    end

    it 'raises a KeyError given a row and no column matches' do
      expect { aggregate.get!('c', 'z') }.to raise_error(KeyError, /key not found: "z"/)
    end
  end

  describe '#get' do
    it 'returns a summed value when given an alias' do
      expect(aggregate.get('a', 'alias')).to eq(3)
    end

    it 'returns an original value when given a row' do
      expect(aggregate.get('b', 'y')).to eq(4)
    end

    it 'returns nil when no column or alias matches' do
      expect(aggregate.get('a', 'z')).to be_nil
    end

    it 'returns nil given an alias and no row matches' do
      expect(aggregate.get('d', 'alias')).to be_nil
    end

    it 'returns nil given a row and no column matches' do
      expect(aggregate.get('c', 'z')).to be_nil
    end
  end
end
