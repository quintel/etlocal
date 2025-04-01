require 'rails_helper'

RSpec.describe Versions do
  let(:config) {
    {
      'versions' => [
        { 'name' => 'latest', 'freeze_date' => nil },
        { 'name' => 'stable.01', 'freeze_date' => '2018-11-19 23:00:00 UTC' }
      ]
    }
  }

  before do
    stub_const('Versions::CONFIG', config)
    Versions.instance_variable_set(:@versions, nil)
  end

  it 'returns all versions' do
    expect(Versions.versions.size).to eq(2)
  end

  it 'finds version by name' do
    expect(Versions.find_by_name('stable.01')).to include('freeze_date' => '2018-11-19 23:00:00 UTC')
  end

  it 'finds version by freeze_date' do
    expect(Versions.find_by_freeze_date('2018-11-19 23:00:00 UTC')).to include('name' => 'stable.01')
  end

  it 'returns the default version when freeze_date is nil' do
    expect(Versions.default_version['name']).to eq('latest')
  end
end
