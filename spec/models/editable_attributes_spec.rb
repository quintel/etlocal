require 'rails_helper'

describe EditableAttribute do
  let(:dataset) { Dataset.new }

  it 'has a key' do
    attribute = EditableAttribute.new(dataset, :key, 1)

    expect(attribute.key).to eq(:key)
  end
end
