# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::EnergyBalance::Runtime do
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

  describe '#IF' do
    it 'permits querying with procs' do
      expect(runtime.IF(true, -> { 50 * 2 }, -> { 20.0 })).to eq(100)
    end

    it 'raises an error when one of the arguments is not a proc' do
      expect { runtime.IF(true, -> { 50 * 2 }, 20.0) }
        .to raise_error(/should be a proc: '-> { 20.0 }'/)
    end
  end
end
