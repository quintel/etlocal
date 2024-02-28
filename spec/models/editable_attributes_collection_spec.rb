require 'rails_helper'
require 'support/graph'

describe EditableAttributesCollection do
  let(:dataset) { FactoryBot.create(:dataset) }

  before do
    2.times do |i|
      Timecop.freeze(Time.now + i)

      commit = FactoryBot.create(:commit, dataset: dataset)

      FactoryBot.create(:dataset_edit, value: (i + 1), commit: commit)
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

  it 'has a default value for present_number_of_apartments_before_1945' do
    expect(editable_attributes.find('present_number_of_apartments_before_1945').value).to eq(84.0)
  end

  it 'does not have a default value for electricity_consumption' do
    expect(editable_attributes
      .find('input_industry_paper_electricity_demand').value).to eq(nil)
  end
end
