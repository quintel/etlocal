require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.new(area: "Ameland")
  }

  it "it initializes a dataset from an Atlas dataset" do
    expect(dataset).to be_a(Dataset)
  end

  it "expects an area attribute to be present" do
    expect(dataset.area).to eq("Ameland")
  end

  describe 'has editable attributes' do
    it "is editable" do
      dataset.editable_attributes.all.each do |attribute|
        expect(dataset).to respond_to(attribute.key)
      end
    end
  end
end
