require 'rails_helper'

describe EditableAttribute do
  it 'has a key' do
    dataset = Dataset.new
    attribute = EditableAttribute.new(dataset, :key, {})

    expect(attribute.key).to eq(:key)
  end
end
