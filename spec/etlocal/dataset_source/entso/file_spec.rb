# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetSource::ENTSO::File do
  let(:content) do
    <<-CSV.strip_heredoc
      DATAFLOW,LAST UPDATE,freq,nrg_bal,siec,unit,geo,TIME_PERIOD,OBS_VALUE,OBS_FLAG
      ESTAT:NRG_BAL_C(1.0),06/06/21 23:00:00,A,AFC,BIOE,TJ,EU27_2020,2019,4709715.099,
      ESTAT:NRG_BAL_C(1.0),06/06/21 23:00:00,A,AFC,C0110,TJ,EU27_2020,2019,65522.356,
      ESTAT:NRG_BAL_C(1.0),06/06/21 23:00:00,A,DL,BIOE,TJ,EU27_2020,2019,110554.518,
      ESTAT:NRG_BAL_C(1.0),06/06/21 23:00:00,A,DL,C0110,TJ,EU27_2020,2019,0.179,
    CSV
  end

  let(:source_file) do
    Tempfile.new('eb.csv').tap do |f|
      f.write(content)
      f.rewind
    end
  end

  describe '.energy_balance' do
    let(:balance) { described_class.energy_balance(CSV.table(source_file.path, converters: [])) }

    it 'converts siec "C0110" columns into a column' do
      expect(balance.row?('Anthracite')).to be(true)
    end

    it 'converts siec "BIOE" columns into a column' do
      expect(balance.row?('Bioenergy')).to be(true)
    end

    it 'converts nrg_bal "AFC" columns into a row' do
      expect(balance.column?('Available for final consumption')).to be(true)
    end

    it 'converts nrg_bal "DL" columns into a row' do
      expect(balance.column?('Distribution losses')).to be(true)
    end

    it 'returns values as a numeric' do
      expect(balance.get('Bioenergy', 'Distribution losses')).to eq(110_554.518)
    end
  end

  it 'creates a queryable runtime using the source file' do
    file = described_class.new('TEST', source_file)
    expect(file.runtime.EB('Anthracite', 'Available for final consumption')).to eq(65_522.356)
  end
end
