# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::EnergyBalance::File do
  let(:content) do
    <<-CSV.strip_heredoc
      nrg_bal,Total,Solid fossil fuels,Anthracite,Coking coal,Additives and oxygenates (excluding biofuel portion)
      Primary production,521523.845,0.0,0.0,0.0,0.0
      Recovered and recycled products,0.0,0.0,0.0,0.0,0.0
      Imports,1372632.522,115242.958,626.829,51410.08,34124.513
      Exports,332623.939,1393.998,0.029,0.0,0.0
      Change in stock,-106280.323,4000.425,-3.99,-2206.713,3620.805
      Gross available energy,1455252.104,117849.385,622.811,49203.366,37745.317
      International maritime bunkers,610.57,0.0,0.0,0.0,0.0
    CSV
  end

  let(:source_file) do
    Tempfile.new('eb.csv').tap do |f|
      f.write(content)
      f.rewind
    end
  end

  describe '.energy_balance' do
    let(:balance) { described_class.energy_balance(CSV.table(source_file.path, converters: [:numeric])) }

    it 'converts :anthracite values into a column' do
      expect(balance.column?('Anthracite')).to be(true)
    end

    it 'converts :solid_fossil_fuels values into a column' do
      expect(balance.column?('Solid fossil fuels')).to be(true)
    end

    it 'converts :additives_and_oxygenates_excluding_biofuel_portion values into a column' do
      expect(balance.column?('Additives and oxygenates (excluding biofuel portion)')).to be(true)
    end

    it 'converts nrg_bal "Primary production" values into a row' do
      expect(balance.row?('Primary production')).to be(true)
    end

    it 'converts nrg_bal "Gross available energy" values into a row' do
      expect(balance.row?('Gross available energy')).to be(true)
    end

    it 'returns values as a numeric' do
      expect(balance.get('Gross available energy', 'Total')).to eq(1_455_252.104)
    end
  end

  it 'creates a queryable runtime using the source file' do
    file = described_class.new('TEST', source_file)
    expect(file.runtime.EB('Gross available energy', 'Coking coal')).to eq(49_203.366)
  end
end
