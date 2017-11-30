require 'rails_helper'

describe DatasetEdit do
  before { dataset.valid? }

  describe "blank dataset edit" do
    let(:dataset) { DatasetEdit.new }

    it "can't have a blank value" do
      expect(dataset).to have(1).errors_on(:value)
    end

    it "can't have a blank key" do
      expect(dataset).to have(1).errors_on(:key)
    end
  end

  describe "must be bigger than or 0" do
    describe "for regular attribute" do
      let(:dataset) { DatasetEdit.new(value: 0) }

      it "is invalid" do
        expect(dataset).to have(0).errors_on(:value)
      end
    end
  end
end
