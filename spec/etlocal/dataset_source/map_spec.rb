# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DatasetSource::Map do
  context 'with no row or column key maps' do
    let(:map) do
      described_class.new(
        'a' => { 'x' => 1, 'y' => 2 },
        'b' => { 'x' => 3, 'y' => 4 }
      )
    end

    it 'returns a value when it exists' do
      expect(map.get('a', 'x')).to eq(1)
    end

    describe '#row?' do
      it 'returns true when the map has a matching row' do
        expect(map.row?('a')).to be(true)
      end

      it 'returns false when the map has no matching row' do
        expect(map.row?('c')).to be(false)
      end
    end

    describe '#column?' do
      it 'returns true when the map has a matching column' do
        expect(map.column?('x')).to be(true)
      end

      it 'returns false when the map has no matching column' do
        expect(map.column?('z')).to be(false)
      end
    end

    describe '#get' do
      it 'returns nil when the row does not exist' do
        expect(map.get('c', 'x')).to be_nil
      end

      it 'returns nil when the column does not exist' do
        expect(map.get('a', 'z')).to be_nil
      end
    end

    describe '#get!' do
      it 'raises KeyError when the row does not exist' do
        expect { map.get!('c', 'x') }.to raise_error(KeyError, /key not found: "c"/)
      end

      it 'raises KeyError when the column does not exist' do
        expect { map.get!('a', 'z') }.to raise_error(KeyError, /key not found: "z"/)
      end
    end
  end

  context 'with row and column key maps' do
    let(:map) do
      described_class.new(
        {
          'a' => { 'x' => 1, 'y' => 2 },
          'b' => { 'x' => 3, 'y' => 4 }
        },
        DatasetSource::KeyMap.from_hash(
          'a_key' => 'a',
          'b_key' => 'b'
        ),
        DatasetSource::KeyMap.from_hash(
          'x_key' => 'x',
          'y_key' => 'y'
        )
      )
    end

    it 'returns a value when it exists' do
      expect(map.get('a_key', 'x_key')).to eq(1)
    end

    it 'returns nil when the row does not exist' do
      expect(map.get('c_key', 'x_key')).to be_nil
    end

    it 'returns nil when the column does not exist' do
      expect(map.get('a_key', 'z_key')).to be_nil
    end

    it 'returns nil when given an original row key' do
      expect(map.get('a', 'x_key')).to be_nil
    end

    it 'returns nil when given an original column key' do
      expect(map.get('a_key', 'x')).to be_nil
    end

    describe '#row?' do
      it 'returns true when the map has a matching row' do
        expect(map.row?('a_key')).to be(true)
      end

      it 'returns false when the map has no matching row' do
        expect(map.row?('a')).to be(false)
      end
    end

    describe '#column?' do
      it 'returns true when the map has a matching column' do
        expect(map.column?('x_key')).to be(true)
      end

      it 'returns false when the map has no matching column' do
        expect(map.column?('x')).to be(false)
      end
    end
  end
end
