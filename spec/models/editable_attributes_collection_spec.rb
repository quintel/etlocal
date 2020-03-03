require 'rails_helper'
require 'support/graph'

describe EditableAttributesCollection do
  let(:dataset) { FactoryGirl.create(:dataset) }

  before do
    2.times do |i|
      Timecop.freeze(Time.now + i)

      commit = FactoryGirl.create(:commit, dataset: dataset)

      FactoryGirl.create(:dataset_edit, value: (i + 1), commit: commit)
    end
  end

  let(:editable_attributes) { EditableAttributesCollection.new(dataset) }

  it 'finds all previous values' do
    expect(editable_attributes.find('number_of_cars').previous.size).to eq(2)
  end

  it 'expands on the graph methods' do
    expect(
      editable_attributes
        .find('input_industry_paper_electricity_demand')
    ).to be_a(EditableAttribute)
  end

  it 'has a value' do
    expect(editable_attributes.find('number_of_cars').value).to eq(2.0)
  end

  it 'has a default value for number_of_residences' do
    expect(editable_attributes.find('number_of_residences').value).to eq(10.0)
  end

  it 'does not have a default value for electricity_consumption' do
    expect(editable_attributes
      .find('input_industry_paper_electricity_demand').value).to eq(nil)
  end
end
