require 'rails_helper'

describe EditableAttribute do
  it 'has a key' do
    dataset = Dataset.new
    attribute = EditableAttribute.new(dataset, :key, {})

    expect(attribute.key).to eq(:key)
  end

  describe 'when the dataset uses an ENTSO source' do
    let(:dataset) { FactoryBot.build(:dataset, data_source: 'entso') }

    before do
      allow(dataset).to receive(:execute_query).and_return(1337)
    end

    context 'when the attribute has an ENTSO query' do
      let(:attribute) do
        described_class.new(dataset, :mykey, {}, 1.0, entso_query: 'myquery')
      end

      it 'returns the executed query value' do
        expect(attribute.value).to eq(1337)
      end
    end

    context 'when the attribute has no ENTSO query' do
      let(:attribute) do
        described_class.new(dataset, :mykey, {}, 1.0)
      end

      it 'returns the attribute value' do
        expect(attribute.value).to eq(1.0)
      end
    end
  end

  describe 'when the dataset uses a DB source' do
    let(:dataset) { FactoryBot.build(:dataset, data_source: 'db') }

    before { allow(dataset).to receive(:execute_query).and_return(1337) }

    context 'when the attribute defines an ENTSO query' do
      let(:attribute) do
        described_class.new(dataset, :mykey, {}, 1.0, entso_query: 'myquery')
      end

      it 'returns the attribute value' do
        expect(attribute.value).to eq(1.0)
      end
    end

    context 'when the attribute has no ENTSO query' do
      let(:attribute) do
        described_class.new(dataset, :mykey, {}, 1.0)
      end

      it 'returns the attribute value' do
        expect(attribute.value).to eq(1.0)
      end
    end
  end
end
