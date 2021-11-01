# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::ENTSO::Runtime do
  let(:map) { DatasetSource::Map.new('a' => { 'x' => '1' }) }
  let(:runtime) { described_class.new('TEST01', map) }

  describe '#EB' do
    it 'permits querying with strings' do
      expect(runtime.EB('a', 'x')).to eq('1')
    end

    it 'permits querying with symbols' do
      expect(runtime.EB(:a, :x)).to eq('1')
    end

    it 'raises a KeyError when given an invalid row' do
      expect { runtime.EB('b', 'x') }
        .to raise_error(/does not have an entry matching row="b" and column="x"/)
    end

    it 'raises a KeyError when given an invalid column' do
      expect { runtime.EB('a', 'y') }
        .to raise_error(/does not have an entry matching row="a" and column="y"/)
    end
  end
end
