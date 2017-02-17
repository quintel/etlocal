require 'rails_helper'

describe DatasetEdit do
  before { dataset.valid? }

  let(:dataset) { DatasetEdit.new }

  it "can't have a blank commit" do
    expect(dataset).to have(1).errors_on(:commit)
  end

  it "can't have a blank source" do
    expect(dataset).to have(1).errors_on(:source)
  end

  it "can't have a blank value" do
    expect(dataset).to have(1).errors_on(:value)
  end

  it "can't have a blank area" do
    expect(dataset).to have(1).errors_on(:dataset_id)
  end

  it "can't have a blank key" do
    expect(dataset).to have(1).errors_on(:key)
  end
end
