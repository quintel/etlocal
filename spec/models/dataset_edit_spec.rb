require 'rails_helper'

describe DatasetEdit do
  before { dataset.valid? }

  let(:dataset) { DatasetEdit.new }

  it "can't have a blank value" do
    expect(dataset).to have(1).errors_on(:value)
  end

  it "can't have a blank key" do
    expect(dataset).to have(1).errors_on(:key)
  end
end
