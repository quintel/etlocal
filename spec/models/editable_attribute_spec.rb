require 'rails_helper'

describe EditableAttribute do
  it 'has a key' do
    dataset = Dataset.new
    attribute = EditableAttribute.new(dataset, :key, {})

    expect(attribute.key).to eq(:key)
  end

  describe "defaults for has_industry" do
    it 'has a default for non-Etsource dataset' do
      dataset = Dataset.new
      attribute = EditableAttribute.new(dataset, :has_industry, {})

      expect(attribute.default).to eq(true)
    end

    it 'has a default for Etsource dataset' do
      dataset = FactoryGirl.create(:dataset)
      attribute = EditableAttribute.new(dataset, :has_industry, {})

      expect(attribute.default).to eq(true)
    end
  end
end
